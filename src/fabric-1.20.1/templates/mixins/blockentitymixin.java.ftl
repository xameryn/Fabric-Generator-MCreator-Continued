package ${package}.mixins;

@Mixin(BlockEntity.class)
public class BlockEntityMixin implements ICustomDataHolder {

    @Unique
    private CompoundTag fabricData = new CompoundTag();

    @Inject(method = "saveAdditional", at = @At("RETURN"))
    private void onSaveAdditional(CompoundTag nbt, CallbackInfo ci) {
        if (!fabricData.isEmpty()) {
            nbt.put("FabricData", fabricData);
        }
    }

    @Inject(method = "load", at = @At("RETURN"))
    private void onLoad(CompoundTag nbt, CallbackInfo ci) {
        if (nbt.contains("FabricData")) {
            fabricData = nbt.getCompound("FabricData");
        }
    }

    @Inject(method = "saveWithoutMetadata", at = @At("RETURN"), cancellable = true)
    private void onSaveWithoutMetadata(CallbackInfoReturnable<CompoundTag> cir) {
        CompoundTag nbt = cir.getReturnValue();
        if (!fabricData.isEmpty()) {
            nbt.put("FabricData", fabricData);
        }
        cir.setReturnValue(nbt);
    }

    @Override
    public CompoundTag getCustomData() {
        return fabricData;
    }

    @Override
    public void setCustomData(CompoundTag data) {
        this.fabricData = data;
    }
}