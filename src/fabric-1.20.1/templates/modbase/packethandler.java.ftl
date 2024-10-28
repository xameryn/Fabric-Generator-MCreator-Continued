<#-- @formatter:off -->
package ${package}.network;

import ${package}.${JavaModName};
import net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking;
import net.fabricmc.fabric.api.networking.v1.PlayerLookup;
import net.fabricmc.fabric.api.networking.v1.PacketSender;
import net.fabricmc.fabric.api.client.networking.v1.ClientPlayNetworking;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.server.network.ServerGamePacketListenerImpl;
import net.minecraft.client.Minecraft;
import net.minecraft.world.level.Level;

public class ${JavaModName}PacketHandler {
    private static final ResourceLocation PLAYER_VARIABLES_SYNC = new ResourceLocation(${JavaModName}.MODID, "player_variables_sync");
    private static final ResourceLocation GLOBAL_VARIABLES_SYNC = new ResourceLocation(${JavaModName}.MODID, "global_variables_sync");

    public static void registerC2SPackets() {
        ServerPlayNetworking.registerGlobalReceiver(PLAYER_VARIABLES_SYNC, 
            (server, player, handler, buf, responseSender) -> handlePlayerVariablesC2S(player, buf, server));
    }

    public static void registerS2CPackets() {
        ClientPlayNetworking.registerGlobalReceiver(PLAYER_VARIABLES_SYNC,
            (client, handler, buf, responseSender) -> handlePlayerVariablesS2C(buf, client));

        ClientPlayNetworking.registerGlobalReceiver(GLOBAL_VARIABLES_SYNC,
            (client, handler, buf, responseSender) -> handleGlobalVariablesS2C(buf, client));
    }

    private static void handlePlayerVariablesC2S(ServerPlayer player, FriendlyByteBuf buf, MinecraftServer server) {
        ${JavaModName}Variables.PlayerVariablesSyncMessage message = new ${JavaModName}Variables.PlayerVariablesSyncMessage(buf);
        server.execute(() -> ${JavaModName}Variables.PlayerVariablesSyncMessage.handleServer(message, player));
    }

    private static void handlePlayerVariablesS2C(FriendlyByteBuf buf, Minecraft client) {
        ${JavaModName}Variables.PlayerVariablesSyncMessage message = new ${JavaModName}Variables.PlayerVariablesSyncMessage(buf);
        client.execute(() -> ${JavaModName}Variables.PlayerVariablesSyncMessage.handleClient(message, client));
    }

    private static void handleGlobalVariablesS2C(FriendlyByteBuf buf, Minecraft client) {
        ${JavaModName}Variables.SavedDataSyncMessage message = new ${JavaModName}Variables.SavedDataSyncMessage(buf);
        client.execute(() -> {
            if (message.type == 0) {
                ${JavaModName}Variables.MapVariables.clientSide = (${JavaModName}Variables.MapVariables) message.data;
            } else {
                ${JavaModName}Variables.WorldVariables.clientSide = (${JavaModName}Variables.WorldVariables) message.data;
            }
        });
    }

    public static void sendToServer(${JavaModName}Variables.PlayerVariablesSyncMessage message) {
        ClientPlayNetworking.send(PLAYER_VARIABLES_SYNC, message.toFriendlyByteBuf());
    }

    public static void sendToPlayer(ServerPlayer player, ${JavaModName}Variables.PlayerVariablesSyncMessage message) {
        ServerPlayNetworking.send(player, PLAYER_VARIABLES_SYNC, message.toFriendlyByteBuf());
    }

    public static void sendToPlayer(ServerPlayer player, ${JavaModName}Variables.SavedDataSyncMessage message) {
        ServerPlayNetworking.send(player, GLOBAL_VARIABLES_SYNC, message.toFriendlyByteBuf());
    }

    public static void sendToAll(Level level, ${JavaModName}Variables.SavedDataSyncMessage message) {
        if (level.isClientSide()) return;
        
        for (ServerPlayer player : PlayerLookup.all(level.getServer())) {
            sendToPlayer(player, message);
        }
    }
}
<#-- @formatter:on -->
