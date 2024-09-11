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