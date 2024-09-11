<#include "procedures.java.ftl">
public ${name}Procedure() {
    UseBlockCallback.EVENT.register((player, world, hand, hitResult) -> {
        if (!(player instanceof LivingEntity) || hand != player.getUsedItemHand())
            return InteractionResult.PASS;

        BlockPos pos = hitResult.getBlockPos();
        Direction direction = hitResult.getDirection();
        BlockPos placePos = pos.relative(direction);
        ItemStack itemStack = player.getItemInHand(hand);

        if (!itemStack.isEmpty() && player.mayUseItemAt(placePos, direction, itemStack)) {
            BlockState placedAgainst = world.getBlockState(pos);
            BlockState placedState = Block.byItem(itemStack.getItem()).getStateForPlacement(new BlockPlaceContext(player, hand, itemStack, hitResult));

            if (placedState != null) {
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
        }

        return InteractionResult.PASS;
    });
}