<#include "procedures.java.ftl">
public ${name}Procedure() {
    ServerTickEvents.START_SERVER_TICK.register((server) -> {
        for (ServerPlayer player : server.getPlayerList().getPlayers()) {
            <#assign dependenciesCode><#compress>
            <@procedureDependenciesCode dependencies, {
                "world": "player.level()",
                "entity": "player"
                }/>
            </#compress></#assign>
            execute(${dependenciesCode});
        }
    });
}