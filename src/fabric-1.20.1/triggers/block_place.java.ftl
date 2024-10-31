<#include "procedures.java.ftl">
public ${name}Procedure() {
    UseBlockCallback.EVENT.register((player, world, hand, hitResult) -> {
        if (!world.isClientSide()) {
            BlockPos pos = hitResult.getBlockPos();
            ItemStack itemStack = player.getItemInHand(hand);
            
            if (!itemStack.isEmpty()) {
                // Run this on the next tick to ensure block is placed
                world.getServer().execute(() -> {
                    BlockPos placePos = pos.relative(hitResult.getDirection());
                    BlockState placedState = world.getBlockState(placePos);
                    BlockState placedAgainst = world.getBlockState(pos);

                    if (!placedState.isAir()) {
                        <#assign dependenciesCode><#compress>
                            <@procedureDependenciesCode dependencies, {
                            "x": "placePos.getX()",
                            "y": "placePos.getY()",
                            "z": "placePos.getZ()",
                            "px": "player.getX()",
                            "py": "player.getY()",
                            "pz": "player.getZ()",
                            "world": "world",
                            "entity": "player",
                            "blockstate": "placedState",
                            "placedagainst": "placedAgainst"
                            }/>
                        </#compress></#assign>
                        execute(${dependenciesCode});
                    }
                });
            }
        }
        return InteractionResult.PASS;
    });
}