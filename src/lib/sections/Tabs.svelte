<script lang="ts">
	import { createTabs, melt } from '@melt-ui/svelte';
	import { cubicInOut } from 'svelte/easing';
	import { crossfade } from 'svelte/transition';
	import classNames from 'classnames';
	import OsTerminalWindow from '../OsTerminalWindow.svelte';
	const {
		elements: { root, list, content, trigger },
		states: { value }
	} = createTabs({
		defaultValue: 'tab-1'
	});

	let className = '';
	export { className as class };

	const triggers = [
		{ id: 'tab-1', title: '🍺 Install Homebrew' },
		{ id: 'tab-2', title: 'Install Ollama' },
		{ id: 'tab-3', title: 'Download model' }
	];

	const [send, receive] = crossfade({
		duration: 250,
		easing: cubicInOut
	});
</script>

<div
	use:melt={$root}
	class={classNames(
		'flex w-full flex-col overflow-hidden rounded-xl shadow-lg  data-[orientation=vertical]:flex-row h-full',
		className
	)}
>
	<div
		use:melt={$list}
		class="flex shrink-0 overflow-x-auto
    data-[orientation=vertical]:flex-col data-[orientation=vertical]:border-r"
		aria-label="Manage your account"
	>
		{#each triggers as triggerItem}
			<div class="grow flex justify-center items-center">
				<button use:melt={$trigger(triggerItem.id)} class="trigger relative w-fit grow-0">
					<span class="z-10">{triggerItem.title}</span>
					{#if $value === triggerItem.id}
						<div
							in:send={{ key: 'trigger' }}
							out:receive={{ key: 'trigger' }}
							class="absolute left-1/2 w-full -translate-x-1/2 rounded-full bg-white h-full z-0"
						></div>
					{/if}
				</button>
			</div>
		{/each}
	</div>
	<div use:melt={$content('tab-1')} class="grow py-6 h-full">
		<OsTerminalWindow
			code={'/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'}
		/>
	</div>
	<div use:melt={$content('tab-2')} class="grow bg-white p-5">
		<p class="mb-5 leading-normal text-neutral-900">
			Change your password here. Click save when you're done.
		</p>
		<fieldset class="mb-4 flex w-full flex-col justify-start">
			<label class="mb-2.5 block text-sm leading-none text-neutral-900" for="newPassword">
				New password
			</label>
			<input id="newPassword" type="password" />
		</fieldset>
		<div class="mt-5 flex justify-end">
			<button class="save">Save changes</button>
		</div>
	</div>
	<div use:melt={$content('tab-3')} class="grow bg-white p-5">
		<p class="mb-5 leading-normal text-neutral-900">
			Change your settings here. Click save when you're done.
		</p>

		<fieldset class="mb-4 flex w-full flex-col justify-start">
			<label class="mb-2.5 block text-sm leading-none text-neutral-900" for="newEmail">
				New email
			</label>
			<input id="newEmail" type="email" />
		</fieldset>
		<div class="mt-5 flex justify-end">
			<button class="save">Save changes</button>
		</div>
	</div>
</div>

<style lang="postcss">
	.trigger {
		@apply rounded-full flex items-center justify-center cursor-default;
		user-select: none;

		font-weight: 500;
		line-height: 1;

		flex: 1;
		height: theme(spacing.12);
		padding-inline: theme(spacing.2);

		&:focus {
			position: relative;
		}

		&:focus-visible {
			@apply z-10 ring-2;
		}

		&[data-state='active'] {
			@apply focus:relative transition-all;

			/* background-color: white; */
			color: theme('colors.lightroom.900');
		}
	}
</style>
