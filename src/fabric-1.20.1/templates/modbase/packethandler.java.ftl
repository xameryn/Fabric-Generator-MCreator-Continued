<#-- @formatter:off -->
package ${package}.network;

import ${package}.${JavaModName};
import net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking;
import net.fabricmc.fabric.api.client.networking.v1.ClientPlayNetworking;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.client.Minecraft;

public class ${JavaModName}PacketHandler {
    public static final ResourceLocation PLAYER_VARIABLES_SYNC = new ResourceLocation(${JavaModName}.MODID, "player_variables_sync");

    public static void registerC2SPackets() {
        ServerPlayNetworking.registerGlobalReceiver(PLAYER_VARIABLES_SYNC, (server, player, handler, buf, responseSender) -> {
            ${JavaModName}Variables.PlayerVariablesSyncMessage message = new ${JavaModName}Variables.PlayerVariablesSyncMessage(buf);
            server.execute(() -> ${JavaModName}Variables.PlayerVariablesSyncMessage.handleServer(message, player));
        });
    }

    public static void registerS2CPackets() {
        ClientPlayNetworking.registerGlobalReceiver(PLAYER_VARIABLES_SYNC, (client, handler, buf, responseSender) -> {
            ${JavaModName}Variables.PlayerVariablesSyncMessage message = new ${JavaModName}Variables.PlayerVariablesSyncMessage(buf);
            client.execute(() -> ${JavaModName}Variables.PlayerVariablesSyncMessage.handleClient(message, client));
        });
    }

    public static void sendToServer(${JavaModName}Variables.PlayerVariablesSyncMessage message) {
        ClientPlayNetworking.send(PLAYER_VARIABLES_SYNC, message.toFriendlyByteBuf());
    }

    public static void sendToPlayer(ServerPlayer player, ${JavaModName}Variables.PlayerVariablesSyncMessage message) {
        ServerPlayNetworking.send(player, PLAYER_VARIABLES_SYNC, message.toFriendlyByteBuf());
    }
}
<#-- @formatter:on -->