<#-- @formatter:off -->
package ${package}.client;

import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.components.toasts.Toast;
import net.minecraft.client.gui.components.toasts.ToastComponent;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.network.chat.Component;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.client.resources.sounds.SimpleSoundInstance;
import net.fabricmc.api.Environment;
import net.fabricmc.api.EnvType;

@Environment(EnvType.CLIENT)
public class ToastManager {
    private static final ResourceLocation TEXTURE = new ResourceLocation("textures/gui/toasts.png");

    public static void showToast(String title, String description, ResourceLocation icon, long duration) {
        Minecraft.getInstance().getToasts().addToast(new CustomToast(title, description, icon, duration));
    }

    private static class CustomToast implements Toast {
        private final Component title;
        private final Component description;
        private final ResourceLocation icon;
        private final long duration;
        private long firstDrawTime;
        private boolean playedSound;

        public CustomToast(String title, String description, ResourceLocation icon, long duration) {
            this.title = Component.literal(title);
            this.description = Component.literal(description);
            this.icon = icon;
            this.duration = duration;
        }

        @Override
        public Visibility render(GuiGraphics graphics, ToastComponent toastComponent, long delta) {
            if (this.firstDrawTime == 0L) {
                this.firstDrawTime = delta;
                if (!this.playedSound) {
                    toastComponent.getMinecraft().getSoundManager().play(
                        SimpleSoundInstance.forUI(SoundEvents.UI_TOAST_IN, 1.0F, 1.0F)
                    );
                    this.playedSound = true;
                }
            }

            graphics.blit(TEXTURE, 0, 0, 0, 32, this.width(), this.height());

            if (icon != null) {
                graphics.blit(icon, 8, 8, 0, 0, 16, 16, 16, 16);
            }

            graphics.drawString(
                toastComponent.getMinecraft().font,
                this.title,
                30, 7,
                0xFF500050,
                false
            );

            graphics.drawString(
                toastComponent.getMinecraft().font,
                this.description,
                30, 18,
                0xFF000000,
                false
            );

            return delta - this.firstDrawTime >= duration ? Visibility.HIDE : Visibility.SHOW;
        }

        @Override
        public int width() {
            return 160;
        }

        @Override
        public int height() {
            return 32;
        }
    }
}

<#-- @formatter:on -->