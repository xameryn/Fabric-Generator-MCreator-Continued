<#include "procedures.java.ftl">
public ${name}Procedure() {
    UseBlockCallback.EVENT.register((player, world, hand, hitResult) -> {
        BlockPos pos = hitResult.getBlockPos();
        ItemStack itemStack = player.getItemInHand(hand);
        
        if (!itemStack.isEmpty() && itemStack.getItem() instanceof BlockItem) {
            BlockPos placePos = pos.relative(hitResult.getDirection());
            
            if (world.isClientSide()) {
                new Thread(() -> {
                    try {
                        Thread.sleep(100);
                        Minecraft.getInstance().execute(() -> {
                            BlockState placedState = world.getBlockState(placePos);
                            if (!placedState.isAir()) {
                                <#assign dependenciesCode><#compress>
                                    <@procedureDependenciesCode dependencies, {
                                    "x": "placePos.getX()",
                                    "y": "placePos.getY()",
                                    "z": "placePos.getZ()",
                                    "world": "world",
                                    "entity": "player",
                                    "blockstate": "placedState"
                                    }/>
                                </#compress></#assign>
                                execute(${dependenciesCode});
                            }
                        });
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }).start();
            } else {
                new Thread(() -> {
                    try {
                        Thread.sleep(100);
                        world.getServer().execute(() -> {
                            BlockState placedState = world.getBlockState(placePos);
                            if (!placedState.isAir()) {
                                <#assign dependenciesCode><#compress>
                                    <@procedureDependenciesCode dependencies, {
                                    "x": "placePos.getX()",
                                    "y": "placePos.getY()",
                                    "z": "placePos.getZ()",
                                    "world": "world",
                                    "entity": "player",
                                    "blockstate": "placedState"
                                    }/>
                                </#compress></#assign>
                                execute(${dependenciesCode});
                            }
                        });
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }).start();
            }
        }
        return InteractionResult.PASS;
    });
}