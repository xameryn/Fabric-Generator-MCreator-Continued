package ${package}.mixins;

@Mixin(Entity.class)
public abstract class EntityMixin {

	@Shadow public abstract void discard();
	@Shadow public abstract double distanceToSqr(Entity entity);
}
<#-- @formatter:on -->
