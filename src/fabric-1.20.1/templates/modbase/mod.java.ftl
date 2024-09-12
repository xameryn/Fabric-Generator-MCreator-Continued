<#-- @formatter:off -->
/*
 *	MCreator note:
 *
 *	If you lock base mod element files, you can edit this file and the proxy files
 *	and they won't get overwritten. If you change your mod package or modid, you
 *	need to apply these changes to this file MANUALLY.
 *
 *
 *	If you do not lock base mod element files in Workspace settings, this file
 *	will be REGENERATED on each build.
 *
 */

package ${package};

import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
<#if w.hasElementsOfType("config")>import ${package}.init.${JavaModName}Configs;</#if>
import ${package}.init.*;


public class ${JavaModName} implements ModInitializer {

	public static final Logger LOGGER = LogManager.getLogger();

	public static final String MODID = "${modid}";

	@Override
	public void onInitialize() {
		LOGGER.info("Initializing ${JavaModName}");

		<#if w.hasElementsOfType("particle")>${JavaModName}ParticleTypes.load();</#if>
		<#if w.hasElementsOfType("tab")>${JavaModName}Tabs.load();</#if>
		<#if w.hasElementsOfType("gamerule")>${JavaModName}GameRules.load();</#if>
		<#if w.hasElementsOfType("enchantment")>${JavaModName}Enchantments.load();</#if>
		<#if w.hasElementsOfType("potioneffect")>${JavaModName}MobEffects.load();</#if>
		<#if w.hasElementsOfType("potion")>${JavaModName}Potions.load();</#if>
		<#if w.hasElementsOfBaseType("entity")>${JavaModName}Entities.load();</#if>
		<#if w.hasElementsOfBaseType("block")>${JavaModName}Blocks.load();</#if>
		<#if w.hasElementsOfBaseType("item")>${JavaModName}Items.load();</#if>
		<#if w.hasElementsOfBaseType("blockentity")>${JavaModName}BlockEntities.load();</#if>
		<#if w.hasElementsOfBaseType("feature")>${JavaModName}Features.load();</#if>
		<#if w.hasElementsOfType("painting")>${JavaModName}Paintings.load();</#if>
		<#if w.hasElementsOfType("procedure")>${JavaModName}Procedures.load();</#if>
		<#if w.hasElementsOfType("command")>${JavaModName}Commands.load();</#if>
		<#if w.hasElementsOfType("itemextension")>${JavaModName}ItemExtensions.load();</#if>
		<#if w.hasElementsOfType("gui")>${JavaModName}Menus.load();</#if>
		<#if w.hasElementsOfType("keybind")>${JavaModName}KeyMappingsServer.serverLoad();</#if>
		<#if w.getGElementsOfType("recipe")?filter(e -> e.recipeType = "Brewing")?size != 0>${JavaModName}BrewingRecipes.load();</#if>
		<#if w.hasElementsOfType("villagertrade")>${JavaModName}Trades.registerTrades();</#if>
		<#if w.hasSounds()>${JavaModName}Sounds.load();</#if>
		<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>${JavaModName}Variables.SyncJoin();</#if>
		<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>${JavaModName}Variables.SyncChangeWorld();</#if>

		${JavaModName}Variables.init();
		${JavaModName}PacketHandler.registerC2SPackets();
		${JavaModName}PacketHandler.registerS2CPackets();

		<#if w.hasElementsOfType("config")>${JavaModName}Configs.register();</#if>

		<#if w.hasElementsOfType("biome")>
			${JavaModName}Biomes.loadEndBiomes();
			ServerLifecycleEvents.SERVER_STARTING.register((server) -> {
				${JavaModName}Biomes.load(server);
			});
		</#if>

		
	}
}
<#-- @formatter:on -->
