<#-- @formatter:off -->
package ${package}.network;

import ${package}.${JavaModName};

import net.minecraft.world.level.storage.LevelResource;
import net.minecraft.world.entity.Entity;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.server.MinecraftServer;
import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.nbt.NbtIo;
import net.minecraft.nbt.Tag;
import net.minecraft.client.Minecraft;

import net.fabricmc.fabric.api.networking.v1.ServerPlayConnectionEvents;
import net.fabricmc.fabric.api.entity.event.v1.ServerPlayerEvents;
import net.fabricmc.fabric.api.networking.v1.PacketByteBufs;

import java.util.UUID;
import java.util.Map;
import java.util.HashMap;
import java.io.IOException;
import java.io.File;

public class ${JavaModName}Variables {

    <#if w.hasVariablesOfScope("GLOBAL_SESSION")>
		<#list variables as var>
			<#if var.getScope().name() == "GLOBAL_SESSION">
				<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_SESSION")['init']?interpret/>
			</#if>
		</#list>
	</#if>

	<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>

		<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>
		public static void SyncJoin() {
			ServerEntityEvents.ENTITY_LOAD.register((entity, world) -> {
				if (entity instanceof Player) {
					if (!world.isClientSide()) {
						SavedData mapdata = MapVariables.get(world);
						SavedData worlddata = WorldVariables.get(world);
					}
				}
			});
		}

		public static void SyncChangeWorld() {
			ServerEntityWorldChangeEvents.AFTER_PLAYER_CHANGE_WORLD.register((player, origin, destination) -> {
				if (!destination.isClientSide()) {
					SavedData worlddata = WorldVariables.get(destination);
				}
			});
		}
		</#if>
	</#if>

	<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>
	public static class WorldVariables extends SavedData {

		public static final String DATA_NAME = "${modid}_worldvars";

		<#list variables as var>
			<#if var.getScope().name() == "GLOBAL_WORLD">
				<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_WORLD")['init']?interpret/>
			</#if>
		</#list>

		public static WorldVariables load(CompoundTag tag) {
			WorldVariables data = new WorldVariables();
			data.read(tag);
			return data;
		}

		public void read(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "GLOBAL_WORLD">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_WORLD")['read']?interpret/>
				</#if>
			</#list>
		}

		@Override public CompoundTag save(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "GLOBAL_WORLD">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_WORLD")['write']?interpret/>
				</#if>
			</#list>
			return nbt;
		}

		public void syncData(LevelAccessor world) {
			this.setDirty();
		}

		static WorldVariables clientSide = new WorldVariables();

		public static WorldVariables get(LevelAccessor world) {
			if (world instanceof ServerLevel level) {
				return level.getDataStorage().computeIfAbsent(e -> WorldVariables.load(e), WorldVariables::new, DATA_NAME);
			} else {
				return clientSide;
			}
		}

	}

	public static class MapVariables extends SavedData {

		public static final String DATA_NAME = "${modid}_mapvars";

		<#list variables as var>
			<#if var.getScope().name() == "GLOBAL_MAP">
				<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_MAP")['init']?interpret/>
			</#if>
		</#list>

		public static MapVariables load(CompoundTag tag) {
			MapVariables data = new MapVariables();
			data.read(tag);
			return data;
		}

		public void read(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "GLOBAL_MAP">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_MAP")['read']?interpret/>
				</#if>
			</#list>
		}

		@Override public CompoundTag save(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "GLOBAL_MAP">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_MAP")['write']?interpret/>
				</#if>
			</#list>
			return nbt;
		}

		public void syncData(LevelAccessor world) {
			this.setDirty();
		}

		static MapVariables clientSide = new MapVariables();

		public static MapVariables get(LevelAccessor world) {
            if (world instanceof ServerLevelAccessor serverLevelAcc) {
                return serverLevelAcc.getLevel().getServer().getLevel(Level.OVERWORLD).getDataStorage()
                        .computeIfAbsent(e -> MapVariables.load(e), MapVariables::new, DATA_NAME);
            } else {
                return clientSide;
            }
        }

	}

	public static class SavedDataSyncMessage {

		public int type;
		public SavedData data;

		public SavedDataSyncMessage(FriendlyByteBuf buffer) {
			this.type = buffer.readInt();
			this.data = this.type == 0 ? new MapVariables() : new WorldVariables();

			if(this.data instanceof MapVariables _mapvars)
				_mapvars.read(buffer.readNbt());
			else if(this.data instanceof WorldVariables _worldvars)
				_worldvars.read(buffer.readNbt());
		}

		public SavedDataSyncMessage(int type, SavedData data) {
			this.type = type;
			this.data = data;
		}

		public static void buffer(SavedDataSyncMessage message, FriendlyByteBuf buffer) {
			buffer.writeInt(message.type);
			buffer.writeNbt(message.data.save(new CompoundTag()));
		}
	}
	</#if>

    public static class PlayerVariables {
        <#list variables as var>
            <#if var.getScope().name() == "PLAYER_PERSISTENT">
                <@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_PERSISTENT")['init']?interpret/>
            </#if>
        </#list>

        public void syncPlayerVariables(Entity entity) {
            if (entity instanceof ServerPlayer serverPlayer)
                ${JavaModName}PacketHandler.sendToPlayer(serverPlayer, new PlayerVariablesSyncMessage(this));
        }

        public CompoundTag writeNBT() {
            CompoundTag nbt = new CompoundTag();
            <#list variables as var>
                <#if var.getScope().name() == "PLAYER_PERSISTENT">
                    <@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_PERSISTENT")['write']?interpret/>
                </#if>
            </#list>
            return nbt;
        }

        public void readNBT(CompoundTag nbt) {
            <#list variables as var>
                <#if var.getScope().name() == "PLAYER_PERSISTENT">
                    <@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_PERSISTENT")['read']?interpret/>
                </#if>
            </#list>
        }
    }

    private static final Map<UUID, PlayerVariables> playerVariables = new HashMap<>();
    private static PlayerVariables clientPlayerVariables = new PlayerVariables();

    public static PlayerVariables getPlayerVariables(Entity entity) {
        if (entity.level().isClientSide()) {
            return clientPlayerVariables;
        } else if (entity instanceof ServerPlayer player) {
            return playerVariables.computeIfAbsent(player.getUUID(), k -> {
                PlayerVariables vars = new PlayerVariables();
                loadPlayerVariables(player);
                return vars;
            });
        }
        return null;
    }

    public static void savePlayerVariables(Entity entity) {
        if (entity instanceof ServerPlayer player) {
            PlayerVariables playerVar = playerVariables.get(player.getUUID());
            if (playerVar != null) {
                saveNBTToFile(player.getServer(), player.getUUID().toString(), playerVar.writeNBT());
            }
        }
    }

    public static void loadPlayerVariables(Entity entity) {
        if (entity instanceof ServerPlayer player) {
            CompoundTag playerData = loadNBTFromFile(player.getServer(), player.getUUID().toString());
            if (playerData != null) {
                PlayerVariables playerVar = playerVariables.computeIfAbsent(player.getUUID(), k -> new PlayerVariables());
                playerVar.readNBT(playerData);
                ${JavaModName}PacketHandler.sendToPlayer(player, new PlayerVariablesSyncMessage(playerVar));
            }
        }
    }

    private static void saveNBTToFile(MinecraftServer server, String fileName, CompoundTag nbt) {
        try {
            File dataDir = new File(server.getWorldPath(LevelResource.PLAYER_DATA_DIR).toFile(), ${JavaModName}.MODID);
            dataDir.mkdirs();
            File file = new File(dataDir, fileName + ".dat");
            NbtIo.writeCompressed(nbt, file);
        } catch (IOException e) {
            ${JavaModName}.LOGGER.error("Failed to save player variables for " + fileName, e);
        }
    }

    private static CompoundTag loadNBTFromFile(MinecraftServer server, String fileName) {
        try {
            File file = new File(server.getWorldPath(LevelResource.PLAYER_DATA_DIR).toFile(), ${JavaModName}.MODID + "/" + fileName + ".dat");
            return file.exists() ? NbtIo.readCompressed(file) : null;
        } catch (IOException e) {
            ${JavaModName}.LOGGER.error("Failed to load player variables for " + fileName, e);
            return null;
        }
    }

    public static class PlayerVariablesSyncMessage {
        public PlayerVariables data;

        public PlayerVariablesSyncMessage(FriendlyByteBuf buffer) {
            this.data = new PlayerVariables();
            this.data.readNBT(buffer.readNbt());
        }

        public PlayerVariablesSyncMessage(PlayerVariables data) {
            this.data = data;
        }

        public static void buffer(PlayerVariablesSyncMessage message, FriendlyByteBuf buffer) {
            buffer.writeNbt(message.data.writeNBT());
        }

        public FriendlyByteBuf toFriendlyByteBuf() {
            FriendlyByteBuf buf = PacketByteBufs.create();
            buffer(this, buf);
            return buf;
        }

        public static void handleClient(PlayerVariablesSyncMessage message, Minecraft minecraft) {
            clientPlayerVariables = message.data;
        }

        public static void handleServer(PlayerVariablesSyncMessage message, ServerPlayer player) {
            PlayerVariables variables = getPlayerVariables(player);
            if (variables != null) {
                variables.readNBT(message.data.writeNBT());
                savePlayerVariables(player);
            }
        }
    }

    public static void init() {
        ServerPlayerEvents.COPY_FROM.register((oldPlayer, newPlayer, alive) -> {
            PlayerVariables oldVariables = getPlayerVariables(oldPlayer);
            PlayerVariables newVariables = new PlayerVariables();
            if (oldVariables != null) {
                <#list variables as var>
                    <#if var.getScope().name() == "PLAYER_PERSISTENT">
                    newVariables.${var.getName()} = oldVariables.${var.getName()};
                    </#if>
                </#list>
            }
            playerVariables.put(newPlayer.getUUID(), newVariables);
            savePlayerVariables(newPlayer);
        });

        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
            loadPlayerVariables(handler.player);
        });

        ServerPlayConnectionEvents.DISCONNECT.register((handler, server) -> {
            savePlayerVariables(handler.player);
            playerVariables.remove(handler.player.getUUID());
        });
    }
}
<#-- @formatter:on -->