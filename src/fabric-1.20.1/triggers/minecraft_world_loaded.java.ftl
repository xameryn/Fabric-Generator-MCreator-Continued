<#include "procedures.java.ftl">
public ${name}Procedure() {
    ServerWorldEvents.LOAD.register((server, level) -> {
        <#assign dependenciesCode><#compress>
        <@procedureDependenciesCode dependencies, {
            "world": "level",
            "server": "server"
        }/>
        </#compress></#assign>
        execute(${dependenciesCode});
    });
}