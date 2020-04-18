﻿#region Copyright & License Information
/*
 * Copyright 2015- OpenRA.Mods.AS Developers (see AUTHORS)
 * This file is a part of a third-party plugin for OpenRA, which is
 * free software. It is made available to you under the terms of the
 * GNU General Public License as published by the Free Software
 * Foundation. For more information, see COPYING.
 */
#endregion

using System.Collections.Generic;
using OpenRA.Mods.Common.Effects;
using OpenRA.Traits;

namespace OpenRA.Mods.AS.Warheads
{
	public class RevealShroudWarhead : WarheadAS
	{
		[Desc("Stances relative to the firer which the warhead affects.")]
		public readonly Stance RevealStances = Stance.Ally;

		[Desc("Duration of the reveal.")]
		public readonly int Duration = 25;

		[Desc("Radius of the reveal around the detonation.")]
		public readonly WDist Radius = new WDist(1536);

		[Desc("Can this warhead reveal shroud generated by the GeneratesShroud trait?")]
		public readonly bool RevealGeneratedShroud = false;

		public override void DoImpact(Target target, Actor firedBy, IEnumerable<int> damageModifiers)
		{
			if (!target.IsValidFor(firedBy))
				return;

			if (!IsValidImpact(target.CenterPosition, firedBy))
				return;

			if (!firedBy.IsDead)
			{
				firedBy.World.AddFrameEndTask(w => w.Add(new RevealShroudEffect(target.CenterPosition, Radius,
					RevealGeneratedShroud ? Shroud.SourceType.Visibility : Shroud.SourceType.PassiveVisibility,
					firedBy.Owner, RevealStances, duration: Duration)));
			}
		}

		/*public override void DoImpact(Target target, WarheadArgs args)
		{
			var firedBy = args.SourceActor;

			if (!target.IsValidFor(firedBy))
				return;

			if (!IsValidImpact(target.CenterPosition, firedBy))
				return;

			if (!firedBy.IsDead)
			{
				firedBy.World.AddFrameEndTask(w => w.Add(new RevealShroudEffect(target.CenterPosition, Radius,
					RevealGeneratedShroud ? Shroud.SourceType.Visibility : Shroud.SourceType.PassiveVisibility,
					firedBy.Owner, RevealStances, duration: Duration)));
			}
		}*/
	}
}
