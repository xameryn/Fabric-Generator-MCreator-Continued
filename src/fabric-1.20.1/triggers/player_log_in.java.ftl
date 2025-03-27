<#include "procedures.java.ftl">
public ${name}Procedure() {
    ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
        <#assign dependenciesCode><#compress>
            <@procedureDependenciesCode dependencies, {
            "x": "handler.getPlayer().getX()",
            "y": "handler.getPlayer().getY()",
            "z": "handler.getPlayer().getZ()",
            "world": "handler.getPlayer().level()",
            "entity": "handler.getPlayer()"
            }/>
        </#compress></#assign>
        execute(${dependenciesCode});
    });

    ClientPlayConnectionEvents.JOIN.register((handler, sender, client) -> {
        <#assign dependenciesCode><#compress>
            <@procedureDependenciesCode dependencies, {
            "x": "client.player.getX()",
            "y": "client.player.getY()",
            "z": "client.player.getZ()",
            "world": "client.player.level()",
            "entity": "client.player"
            }/>
        </#compress></#assign>
        execute(${dependenciesCode});
    });
}