<#--
 # This file is part of Fabric-Generator-MCreator.
 # Copyright (C) 2020-2022, Goldorion, opensource contributors
 #
 # Fabric-Generator-MCreator is free software: you can redistribute it and/or modify
 # it under the terms of the GNU Lesser General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.

 # Fabric-Generator-MCreator is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 # GNU Lesser General Public License for more details.
 #
 # You should have received a copy of the GNU Lesser General Public License
 # along with Fabric-Generator-MCreator.  If not, see <https://www.gnu.org/licenses/>.
-->

<#-- @formatter:off -->
/*
 *	MCreator note: This file will be REGENERATED on each build.
 */
<#compress>
<#include "../mcitems.ftl">

package ${package}.init;

import net.fabricmc.fabric.api.itemgroup.v1.FabricItemGroup;

public class ${JavaModName}Tabs {

	<#list tabs as tab>
		public static CreativeModeTab TAB_${tab.getModElement().getRegistryNameUpper()};
	</#list>

	public static void load() {
		<#list tabs as tab>
		TAB_${tab.getModElement().getRegistryNameUpper()} = FabricItemGroup
					.builder(new ResourceLocation("${modid}","${tab.getModElement().getRegistryName()}"))
					.icon(()-> ${mappedMCItemToItemStackCode(tab.icon, 1)})
					.displayItems((enabledFeatures, entries, operatorEnabled) -> {
					})
					.build();
		</#list>
	}

}
</#compress>
<#-- @formatter:on -->