<#-- @formatter:off -->
package ${package}.network;

import ${package}.${JavaModName};

import net.minecraft.world.level.storage.LevelResource;
import net.minecraft.world.level.LevelAccessor;
import net.minecraft.world.entity.Entity;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.MinecraftServer;
import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.nbt.NbtIo;
import net.minecraft.nbt.Tag;
import net.minecraft.client.Minecraft;
import net.minecraft.world.level.Level;
import net.minecraft.nbt.ListTag;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;

import net.fabricmc.fabric.api.networking.v1.ServerPlayConnectionEvents;
import net.fabricmc.fabric.api.entity.event.v1.ServerPlayerEvents;
import net.fabricmc.fabric.api.networking.v1.PacketByteBufs;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerLifecycleEvents;

import java.util.UUID;
import java.util.Map;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;
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
		public static void SyncJoin() {
			ServerEntityEvents.ENTITY_LOAD.register((entity, world) -> {
				if (entity instanceof ServerPlayer player) {
					if (!world.isClientSide()) {
						// Sync both map and world variables to the joining player
						MapVariables mapdata = MapVariables.get(world);
						WorldVariables worlddata = WorldVariables.get(world);
						
						${JavaModName}PacketHandler.sendToPlayer(player, new SavedDataSyncMessage(0, mapdata));
						${JavaModName}PacketHandler.sendToPlayer(player, new SavedDataSyncMessage(1, worlddata));
					}
				}
			});
		}

		public static void SyncChangeWorld() {
			ServerEntityWorldChangeEvents.AFTER_PLAYER_CHANGE_WORLD.register((player, origin, destination) -> {
				if (!destination.isClientSide()) {
					// Sync world variables when player changes dimension
					WorldVariables worlddata = WorldVariables.get(destination);
					${JavaModName}PacketHandler.sendToPlayer(player, new SavedDataSyncMessage(1, worlddata));
				}
			});
		}
	</#if>

	<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>
	public static class WorldVariables extends SavedData {

		private static final String DATA_NAME = "${modid}_worldvars";
		public static WorldVariables clientSide = new WorldVariables(); // Changed to public
		private boolean dirty = false;

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
			if (!dirty) return;
			
			this.setDirty();
			if (world instanceof ServerLevel level) {
				SavedDataSyncMessage msg = new SavedDataSyncMessage(1, this);
				${JavaModName}PacketHandler.sendToAll(level, msg);
			}
			dirty = false;
		}

		public void markDirty() {
			dirty = true;
		}

		public static WorldVariables get(LevelAccessor world) {
			if (world instanceof ServerLevel level) {
				return level.getDataStorage().computeIfAbsent(e -> WorldVariables.load(e), WorldVariables::new, DATA_NAME);
			} else {
				return clientSide;
			}
		}

		// Add this method inside both WorldVariables and MapVariables classes
		private ListTag saveArrayList(ArrayList<?> list) {
			ListTag listTag = new ListTag();
			for (Object e : list) {
				CompoundTag tag = new CompoundTag();
				if (e instanceof String) 
					tag.putString("value", (String)e);
				else if (e instanceof Number) 
					tag.putDouble("value", ((Number)e).doubleValue());
				else if (e instanceof Boolean) 
					tag.putBoolean("value", (Boolean)e);
				else if (e instanceof ArrayList) 
					tag.put("value", saveArrayList((ArrayList<?>)e));
				listTag.add(tag);
			}
			return listTag;
		}

		// Add this inside both WorldVariables and MapVariables classes, next to the saveArrayList method:

		private ArrayList<?> loadArrayList(ListTag listTag) {
			ArrayList<Object> list = new ArrayList<>();
			for (Tag e : listTag) {
				CompoundTag tag = (CompoundTag)e;
				Tag value = tag.get("value");
				if (value instanceof StringTag)
					list.add(tag.getString("value"));
				else if (value instanceof NumericTag)
					list.add(tag.getDouble("value"));
				else if (value instanceof ByteTag)
					list.add(tag.getBoolean("value"));
				else if (value instanceof ListTag)
					list.add(loadArrayList((ListTag)value));
			}
			return list;
		}

	}

	public static class MapVariables extends SavedData {

		private static final String DATA_NAME = "${modid}_mapvars";
		public static MapVariables clientSide = new MapVariables(); // Changed to public
		private boolean dirty = false;

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
			if (!dirty) return;
			
			this.setDirty();
			if (world instanceof ServerLevel level) {
				// Save to disk
				level.getServer().getLevel(Level.OVERWORLD).getDataStorage()
					.save(); // Add this line to force save
				
				// Sync to clients
				SavedDataSyncMessage msg = new SavedDataSyncMessage(0, this);
				${JavaModName}PacketHandler.sendToAll(level, msg);
			}
			dirty = false;
		}

		public void markDirty() {
			dirty = true;
		}

		public static MapVariables get(LevelAccessor world) {
			if (world instanceof ServerLevel level) {
				ServerLevel overworld = level.getServer().getLevel(Level.OVERWORLD);
				return overworld.getDataStorage()
						.computeIfAbsent(e -> MapVariables.load(e), MapVariables::new, DATA_NAME);
			} else {
				return clientSide;
			}
		}

		// Add this method inside both WorldVariables and MapVariables classes
		private ListTag saveArrayList(ArrayList<?> list) {
			ListTag listTag = new ListTag();
			for (Object e : list) {
				CompoundTag tag = new CompoundTag();
				if (e instanceof String) 
					tag.putString("value", (String)e);
				else if (e instanceof Number) 
					tag.putDouble("value", ((Number)e).doubleValue());
				else if (e instanceof Boolean) 
					tag.putBoolean("value", (Boolean)e);
				else if (e instanceof ArrayList) 
					tag.put("value", saveArrayList((ArrayList<?>)e));
				listTag.add(tag);
			}
			return listTag;
		}

		// Add this inside both WorldVariables and MapVariables classes, next to the saveArrayList method:

		private ArrayList<?> loadArrayList(ListTag listTag) {
			ArrayList<Object> list = new ArrayList<>();
			for (Tag e : listTag) {
				CompoundTag tag = (CompoundTag)e;
				Tag value = tag.get("value");
				if (value instanceof StringTag)
					list.add(tag.getString("value"));
				else if (value instanceof NumericTag)
					list.add(tag.getDouble("value"));
				else if (value instanceof ByteTag)
					list.add(tag.getBoolean("value"));
				else if (value instanceof ListTag)
					list.add(loadArrayList((ListTag)value));
			}
			return list;
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

		public FriendlyByteBuf toFriendlyByteBuf() {
			FriendlyByteBuf buf = PacketByteBufs.create();
			buffer(this, buf);
			return buf;
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

    private static final Map<UUID, PlayerVariables> playerVariables = new ConcurrentHashMap<>(); // Changed from HashMap
    private static PlayerVariables clientPlayerVariables = new PlayerVariables();

    public static PlayerVariables getPlayerVariables(Entity entity) {
        if (entity == null) return null;
        
        if (entity.level().isClientSide()) {
            return clientPlayerVariables;
        } else if (entity instanceof ServerPlayer player) {
            UUID playerId = player.getUUID();
            if (!playerVariables.containsKey(playerId)) {
                PlayerVariables vars = new PlayerVariables();
                loadPlayerVariables(player);
                playerVariables.put(playerId, vars);
                return vars;
            }
            return playerVariables.get(playerId);
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
            if (oldPlayer == null || newPlayer == null) return;
            
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
            if (handler.player != null) {
                loadPlayerVariables(handler.player);
            }
        });

        ServerPlayConnectionEvents.DISCONNECT.register((handler, server) -> {
            if (handler.player != null) {
                savePlayerVariables(handler.player);
                playerVariables.remove(handler.player.getUUID());
            }
        });

        // Change SERVER_STARTING to SERVER_STARTED and add null checks
        ServerLifecycleEvents.SERVER_STARTED.register(server -> {
            try {
                ServerLevel overworld = server.getLevel(Level.OVERWORLD);
                if (overworld != null) {
                    // Force load map variables
                    MapVariables mapVars = overworld.getDataStorage()
                        .computeIfAbsent(e -> MapVariables.load(e), MapVariables::new, MapVariables.DATA_NAME);
                    mapVars.setDirty();
                }
                
                // Force load world variables for each dimension
                for (ServerLevel level : server.getAllLevels()) {
                    if (level != null) {
                        WorldVariables worldVars = level.getDataStorage()
                            .computeIfAbsent(e -> WorldVariables.load(e), WorldVariables::new, WorldVariables.DATA_NAME);
                        worldVars.setDirty();
                    }
                }
            } catch (Exception e) {
                ${JavaModName}.LOGGER.error("Failed to initialize global variables", e);
            }
        });
    }
}
<#-- @formatter:on -->

