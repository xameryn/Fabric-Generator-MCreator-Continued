package ${package}.network;

import ${package}.${JavaModName};
import net.fabricmc.api.Environment;
import net.fabricmc.api.EnvType;
import net.fabricmc.fabric.api.client.networking.v1.ClientPlayNetworking;
import net.minecraft.client.Minecraft;
import net.minecraft.network.FriendlyByteBuf;

@Environment(EnvType.CLIENT)
public class ${JavaModName}ClientPacketHandler {
    
    public static void registerS2CPackets() {
        ClientPlayNetworking.registerGlobalReceiver(${JavaModName}PacketHandler.PLAYER_VARIABLES_SYNC,
            (client, handler, buf, responseSender) -> handlePlayerVariablesS2C(buf, client));

        ClientPlayNetworking.registerGlobalReceiver(${JavaModName}PacketHandler.GLOBAL_VARIABLES_SYNC,
            (client, handler, buf, responseSender) -> handleGlobalVariablesS2C(buf, client));
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
        ClientPlayNetworking.send(${JavaModName}PacketHandler.PLAYER_VARIABLES_SYNC, message.toFriendlyByteBuf());
    }
} 