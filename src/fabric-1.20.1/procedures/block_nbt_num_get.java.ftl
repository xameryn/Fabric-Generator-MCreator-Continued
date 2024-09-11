<#include "mcelements.ftl">
<#-- @formatter:off -->
(new Object(){
    public double getValue(LevelAccessor world, BlockPos pos, String tag) {
        return BlockTagHelper.getDouble(world, pos, tag);
    }
}.getValue(world, BlockPos.containing(${input$x}, ${input$y}, ${input$z}), ${input$tagName}))
<#-- @formatter:on -->