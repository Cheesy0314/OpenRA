#region Copyright & License Information
/*
 * Copyright 2007-2018 The OpenRA Developers (see AUTHORS)
 * This file is part of OpenRA, which is free software. It is made
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version. For more
 * information, see COPYING.
 */
#endregion

using System;
using System.Collections.Generic;
using System.Linq;
using OpenRA.Mods.Common.Traits;
using OpenRA.Traits;

namespace OpenRA.Mods.RA2.Traits
{
	[Desc("This actor can mind control other actors.")]
	public class MindControllerInfo : PausableConditionalTraitInfo, Requires<ArmamentInfo>, Requires<HealthInfo>
	{
		[Desc("Name of the armament used for mindcontrol targeting and activation.")]
		public readonly string Name = "primary";

		[Desc("Up to how many units can this unit control?",
			"Use 0 or negative numbers for infinite.")]
		public readonly int Capacity = 1;

		[Desc("If the capacity is reached, discard the oldest mind controlled unit and control the new one",
			"If false, controlling new units is forbidden after capacity is reached.")]
		public readonly bool DiscardOldest = true;

		[Desc("Condition to grant to self when controlling actors. Can stack up by the number of enslaved actors. You can use this to forbid firing of the dummy MC weapon.")]
		[GrantedConditionReference]
		public readonly string ControllingCondition;

		[Desc("The sound played when the unit is mindcontrolled.")]
		public readonly string[] Sounds = { };

        public readonly bool Overload = false;

        public readonly string OverloadCondition = null;

        public override object Create(ActorInitializer init) { return new MindController(init.Self, this); }
	}

	public class MindController : PausableConditionalTrait<MindControllerInfo>, INotifyAttack, INotifyKilled, INotifyActorDisposing, INotifyCreated, ITick
	{
		readonly MindControllerInfo info;
		readonly List<Actor> slaves = new List<Actor>();
        int mindControlOverloadConditionToken = ConditionManager.InvalidConditionToken;

		Stack<int> controllingTokens = new Stack<int>();
		ConditionManager conditionManager;

		public IEnumerable<Actor> Slaves { get { return slaves; } }

		public MindController(Actor self, MindControllerInfo info)
			: base(info)
		{
			this.info = info;
		}

		protected override void Created(Actor self)
		{
			conditionManager = self.TraitOrDefault<ConditionManager>();
		}

		void StackControllingCondition(Actor self, string condition)
		{
			if (conditionManager == null)
				return;

			if (string.IsNullOrEmpty(condition))
				return;

			controllingTokens.Push(conditionManager.GrantCondition(self, condition));
		}

		void UnstackControllingCondition(Actor self, string condition)
		{
			if (conditionManager == null)
				return;

			if (string.IsNullOrEmpty(condition))
				return;

			conditionManager.RevokeCondition(self, controllingTokens.Pop());
		}

		public void UnlinkSlave(Actor self, Actor slave)
		{
			if (slaves.Contains(slave))
			{
				slaves.Remove(slave);
				UnstackControllingCondition(self, info.ControllingCondition);
			}
		}

		public void PreparingAttack(Actor self, Target target, Armament a, Barrel barrel) { }

		public void Attacking(Actor self, Target target, Armament a, Barrel barrel)
		{
			if (IsTraitDisabled || IsTraitPaused)
				return;

			if (info.Name != a.Info.Name)
				return;

			if (target.Actor == null || !target.IsValidFor(self))
				return;

			if (self.Owner.Stances[target.Actor.Owner] == Stance.Ally)
				return;

			var mindControllable = target.Actor.TraitOrDefault<MindControllable>();

			if (mindControllable == null)
			{
				throw new InvalidOperationException(
					"`{0}` tried to mindcontrol `{1}`, but the latter does not have the necessary trait!"
					.F(self.Info.Name, target.Actor.Info.Name));
			}

			if (mindControllable.IsTraitDisabled || mindControllable.IsTraitPaused)
				return;

			if (info.Capacity > 0 && !info.DiscardOldest && slaves.Count() >= info.Capacity && !info.Overload)
				return;

			slaves.Add(target.Actor);
			StackControllingCondition(self, info.ControllingCondition);
			mindControllable.LinkMaster(target.Actor, self);

			if (info.Sounds.Any())
				Game.Sound.Play(SoundType.World, info.Sounds.Random(self.World.SharedRandom), self.CenterPosition);

			if (info.Capacity > 0 && info.DiscardOldest && slaves.Count() > info.Capacity)
				slaves[0].Trait<MindControllable>().RevokeMindControl(slaves[0]);


            if (info.Capacity > 0 && info.Overload && slaves.Count() > info.Capacity && mindControlOverloadConditionToken == ConditionManager.InvalidConditionToken)
                mindControlOverloadConditionToken = conditionManager.GrantCondition(self, info.OverloadCondition); //Overload!
        }

		void ReleaseSlaves(Actor self)
		{
			foreach (var s in slaves)
			{
				if (s.IsDead || s.Disposed)
					continue;

				s.Trait<MindControllable>().RevokeMindControl(s);
			}

			slaves.Clear();
			while (controllingTokens.Any())
				UnstackControllingCondition(self, info.ControllingCondition);
		}

		void INotifyKilled.Killed(Actor self, AttackInfo e)
		{
			ReleaseSlaves(self);
		}

		void INotifyActorDisposing.Disposing(Actor self)
		{
			ReleaseSlaves(self);
		}

		protected override void TraitDisabled(Actor self)
		{
			ReleaseSlaves(self);
		}

        public void Tick(Actor self)
        {
            if (info.Capacity > 0 && info.Overload && slaves.Count() > info.Capacity && mindControlOverloadConditionToken == ConditionManager.InvalidConditionToken)
            {
                mindControlOverloadConditionToken = conditionManager.GrantCondition(self, info.OverloadCondition); //Overload!
            }
            else if (info.Capacity > 0 && info.Overload && slaves.Count() <= info.Capacity && mindControlOverloadConditionToken != ConditionManager.InvalidConditionToken)
            {
                mindControlOverloadConditionToken = conditionManager.RevokeCondition(self, mindControlOverloadConditionToken);//Safe
            }
        }
    }
}
