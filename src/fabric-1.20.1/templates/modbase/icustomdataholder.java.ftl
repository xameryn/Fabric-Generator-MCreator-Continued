<#-- @formatter:off -->
package ${package}.util;

import net.minecraft.nbt.CompoundTag;

public interface ICustomDataHolder {
    CompoundTag getCustomData();
    void setCustomData(CompoundTag data);
}
<#-- @formatter:on -->