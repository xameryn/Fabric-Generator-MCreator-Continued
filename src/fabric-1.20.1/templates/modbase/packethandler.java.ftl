<#-- @formatter:off -->
package ${package}.network;

import ${package}.${JavaModName};
import net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking;
import net.fabricmc.fabric.api.networking.v1.PlayerLookup;
import net.fabricmc.fabric.api.networking.v1.PacketSender;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.server.network.ServerGamePacketListenerImpl;
import net.minecraft.world.level.Level;
import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.server.MinecraftServer;

public class ${JavaModName}PacketHandler {
    public static final ResourceLocation PLAYER_VARIABLES_SYNC = new ResourceLocation(${JavaModName}.MODID, "player_variables_sync");
    public static final ResourceLocation GLOBAL_VARIABLES_SYNC = new ResourceLocation(${JavaModName}.MODID, "global_variables_sync");
    public static final ResourceLocation BLOCK_PLACE = new ResourceLocation(${JavaModName}.MODID, "block_place");

    public static void registerC2SPackets() {
        ServerPlayNetworking.registerGlobalReceiver(PLAYER_VARIABLES_SYNC, 
            (server, player, handler, buf, responseSender) -> handlePlayerVariablesC2S(player, buf, server));
    }

    private static void handlePlayerVariablesC2S(ServerPlayer player, FriendlyByteBuf buf, MinecraftServer server) {
        ${JavaModName}Variables.PlayerVariablesSyncMessage message = new ${JavaModName}Variables.PlayerVariablesSyncMessage(buf);
        server.execute(() -> ${JavaModName}Variables.PlayerVariablesSyncMessage.handleServer(message, player));
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
