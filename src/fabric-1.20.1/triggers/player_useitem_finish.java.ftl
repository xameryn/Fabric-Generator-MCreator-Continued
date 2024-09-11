<#include "procedures.java.ftl">
public ${name}Procedure() {
    UseItemCallback.EVENT.register((player, world, hand) -> {
        ItemStack itemstack = player.getItemInHand(hand);
        <#assign dependenciesCode><#compress>
            <@procedureDependenciesCode dependencies, {
            "x": "player.getX()",
            "y": "player.getY()",
            "z": "player.getZ()",
            "itemstack": "itemstack",
            "world": "world",
            "entity": "player"
            }/>
        </#compress></#assign>
        execute(${dependenciesCode});
        
        return TypedActionResult.pass(itemstack);
    });
}