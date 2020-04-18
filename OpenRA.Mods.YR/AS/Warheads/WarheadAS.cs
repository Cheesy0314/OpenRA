#region Copyright & License Information
/*
 * Copyright 2015- OpenRA.Mods.AS Developers (see AUTHORS)
 * This file is a part of a third-party plugin for OpenRA, which is
 * free software. It is made available to you under the terms of the
 * GNU General Public License as published by the Free Software
 * Foundation. For more information, see COPYING.
 */
#endregion

using System.Collections.Generic;
using System.Linq;
using OpenRA.GameRules;
using OpenRA.Mods.Common;
using OpenRA.Mods.Common.Traits;
using OpenRA.Mods.Common.Warheads;
using OpenRA.Primitives;
using OpenRA.Traits;

namespace OpenRA.Mods.AS.Warheads
{
	[Desc("AS warhead extension class." +
		"These warheads check for the Air TargetType when detonated inair!")]

	public abstract class WarheadAS : Warhead
	{
       		[Desc("How much (raw) damage to deal.")]
        	public readonly int Damage = 0;

                [Desc("Types of damage that this warhead causes. Leave empty for no damage types.")]
                public readonly BitSet<DamageType> DamageTypes = default(BitSet<DamageType>);

                [Desc("Damage percentage versus each armortype.")]
                public readonly Dictionary<string, int> Versus = new Dictionary<string, int>();

		public enum ImpactType
		{
			None,
			Ground,
			Air,
			TargetHit
		}

		public ImpactType GetImpactType(World world, CPos cell, WPos pos, Actor firedBy)
		{
			// Missiles need a margin because they sometimes explode a little above ground
			// due to their explosion check triggering slightly too early (because of CloseEnough).
			// TODO: Base ImpactType on target altitude instead of explosion altitude.
			var airMargin = new WDist(128);

			// Matching target actor
			if (GetDirectHit(world, cell, pos, firedBy, true))
				return ImpactType.TargetHit;

			var dat = world.Map.DistanceAboveTerrain(pos);

			if (dat.Length > airMargin.Length)
				return ImpactType.Air;

			return ImpactType.Ground;
		}

		public bool GetDirectHit(World world, CPos cell, WPos pos, Actor firedBy, bool checkTargetType = false)
		{
			foreach (var victim in world.FindActorsOnCircle(pos, WDist.Zero))
			{
				if (checkTargetType && !IsValidAgainst(victim, firedBy))
					continue;

				var healthInfo = victim.Info.TraitInfoOrDefault<HealthInfo>();
				if (healthInfo == null)
					continue;

				// If the impact position is within any HitShape, we have a direct hit
				var activeShapes = victim.TraitsImplementing<HitShape>().Where(Exts.IsTraitEnabled);
				if (activeShapes.Any(i => i.Info.Type.DistanceFromEdge(pos, victim.CenterPosition, victim.Orientation).Length <= 0))
					return true;
			}

			return false;
		}

		public bool IsValidImpact(WPos pos, Actor firedBy)
		{
			var world = firedBy.World;
			var targetTile = world.Map.CellContaining(pos);
			if (!world.Map.Contains(targetTile))
				return false;

			var impactType = GetImpactType(world, targetTile, pos, firedBy);
			var validImpact = false;
			switch (impactType)
			{
				case ImpactType.TargetHit:
					validImpact = true;
					break;
				case ImpactType.Air:
					validImpact = IsValidTarget(new BitSet<TargetableType>("Air"));
					break;
				case ImpactType.Ground:
					var tileInfo = world.Map.GetTerrainInfo(targetTile);
					validImpact = IsValidTarget(tileInfo.TargetTypes);
					break;
			}

			return validImpact;
		}

                public override void DoImpact(Target target, WarheadArgs args)
                {
                        var firedBy = args.SourceActor;

                        // Used by traits or warheads that damage a single actor, rather than a position
                        if (target.Type == TargetType.Actor)
                        {
                                var victim = target.Actor;

                                if (!IsValidAgainst(victim, firedBy))
                                        return;

                                var closestActiveShape = victim.TraitsImplementing<HitShape>().Where(Exts.IsTraitEnabled)
                                        .MinByOrDefault(t => t.DistanceFromEdge(victim, victim.CenterPosition));

                                // Cannot be damaged without an active HitShape
                                if (closestActiveShape == null)
                                        return;

                                InflictDamage(victim, firedBy, closestActiveShape.Info, args.DamageModifiers);
                        }
                        else if (target.Type != TargetType.Invalid)
                                DoImpact(target, firedBy, args.DamageModifiers);
                }

                protected virtual void InflictDamage(Actor victim, Actor firedBy, HitShapeInfo hitshapeInfo, IEnumerable<int> damageModifiers)
                {
                        var damage = Util.ApplyPercentageModifiers(Damage, damageModifiers.Append(DamageVersus(victim, hitshapeInfo)));
                        victim.InflictDamage(firedBy, new Damage(damage, DamageTypes));
                }

                public int DamageVersus(Actor victim, HitShapeInfo shapeInfo)
                {
                        // If no Versus values are defined, DamageVersus would return 100 anyway, so we might as well do that early.
                        if (Versus.Count == 0)
                                return 100;

                        var armor = victim.TraitsImplementing<Armor>()
                                .Where(a => !a.IsTraitDisabled && a.Info.Type != null && Versus.ContainsKey(a.Info.Type) &&
                                        (shapeInfo.ArmorTypes == default(BitSet<ArmorType>) || shapeInfo.ArmorTypes.Contains(a.Info.Type)))
                                .Select(a => Versus[a.Info.Type]);

                        return Util.ApplyPercentageModifiers(100, armor);
                }

                public abstract void DoImpact(Target target, Actor firedBy, IEnumerable<int> damageModifiers);
	}
}
