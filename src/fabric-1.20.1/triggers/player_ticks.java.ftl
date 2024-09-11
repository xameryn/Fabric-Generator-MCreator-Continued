<#include "procedures.java.ftl">
public ${name}Procedure() {
    ServerTickEvents.START_SERVER_TICK.register((server) -> {
        for (ServerPlayer player : server.getPlayerList().getPlayers()) {
            Level level = player.level();
            Vec3 pos = player.position();
            <#assign dependenciesCode><#compress>
            <@procedureDependenciesCode dependencies, {
                "x": "pos.x",
                "y": "pos.y",
                "z": "pos.z",
                "world": "level",
                "entity": "player"
            }/>
            </#compress></#assign>
            execute(${dependenciesCode});
        }
    });
}