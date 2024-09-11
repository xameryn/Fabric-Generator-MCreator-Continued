<#include "procedures.java.ftl">
public class ${name}Procedure {
    public ${name}Procedure() {
        ServerWorldEvents.LOAD.register((MinecraftServer server, ServerWorld world) -> {
            <#assign dependenciesCode><#compress>
            <@procedureDependenciesCode dependencies, {
                "world": "world"
            }/>
            </#compress></#assign>
            execute(${dependenciesCode});
        });
    }
}