<#include "procedures.java.ftl">
public ${name}Procedure() {
    UseBlockCallback.EVENT.register((player, world, hand, hitResult) -> {
        if (!world.isClientSide() && player instanceof ServerPlayer serverPlayer) {
            BlockPos placePos = hitResult.getBlockPos().relative(hitResult.getDirection());
            ItemStack heldItem = player.getItemInHand(hand);
            
            if (heldItem.getItem() instanceof SignItem) {
                world.getServer().tell(new TickTask(5, () -> {
                    BlockState state = world.getBlockState(placePos);
                    if (state.getBlock() instanceof SignBlock) {
                        <#assign dependenciesCode><#compress>
                            <@procedureDependenciesCode dependencies, {
                            "x": "placePos.getX()",
                            "y": "placePos.getY()",
                            "z": "placePos.getZ()",
                            "world": "world",
                            "entity": "player",
                            "blockstate": "state"
                            }/>
                        </#compress></#assign>
                        execute(${dependenciesCode});
                    }
                }));
            }
        }
        return InteractionResult.PASS;
    });
}