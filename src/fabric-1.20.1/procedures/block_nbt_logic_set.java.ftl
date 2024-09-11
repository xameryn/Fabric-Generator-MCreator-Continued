<#include "mcelements.ftl">
if(!world.isClientSide()) {
	BlockPos _bp = ${toBlockPos(input$x,input$y,input$z)};
	BlockEntity _blockEntity = world.getBlockEntity(_bp);
	BlockState _bs = world.getBlockState(_bp);
	if(_blockEntity != null)
		BlockTagHelper.setBoolean(world, BlockPos.containing(x, y, z), ${input$tagName}, ${input$tagValue});
}