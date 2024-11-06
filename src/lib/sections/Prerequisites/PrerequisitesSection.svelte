<script lang="ts">
	import { Tabs } from 'bits-ui';
	import Highlight from 'svelte-highlight';
	import { bash } from 'svelte-highlight/languages';
	import { materialDarker } from 'svelte-highlight/styles';
	import { CopyIcon } from 'lucide-svelte';
</script>

<svelte:head>
	{@html materialDarker}
</svelte:head>
<section class="bg-lightroom-900 text-white h-[80vh] flex items-center">
	<div class="container flex flex-col gap-6 justify-center items-center">
		<h2>Breed your llama</h2>
		<div class="max-w-lg text-center text-lightroom-200">
			<p>In order for the plugin to work, you need an ollama.</p>
			<p>Open a terminal and follow these simple steps to get started.</p>
		</div>

		<Tabs.Root class="w-full h-full flex flex-col gap-6">
			<Tabs.List
				class="grid grid-cols-3 w-full font-medium gap-6 items-center justify-center bg-lightroom-950 rounded-full p-2 relative"
			>
				<Tabs.Trigger
					value="tab-homebrew"
					class="px-4 py-2 rounded-full bg-transparent data-[state=active]:bg-white data-[state=active]:text-lightroom-950"
					>🍺 Install Homebrew</Tabs.Trigger
				>
				<Tabs.Trigger
					value="tab-ollama"
					class="px-4 py-2 rounded-full bg-transparent data-[state=active]:bg-white data-[state=active]:text-lightroom-950"
					>🦙 Install Ollama</Tabs.Trigger
				>
				<Tabs.Trigger
					value="tab-model"
					class="px-4 py-2 rounded-full bg-transparent data-[state=active]:bg-white data-[state=active]:text-lightroom-950"
					>💾 Download model</Tabs.Trigger
				>
			</Tabs.List>
			<Tabs.Content value="tab-homebrew">
				<div class="h-64">
					<div class="h-fit relative overflow-hidden rounded-3xl">
						<Highlight
							language={bash}
							code={`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`}
							class="overflow-hidden"
						/>
						<div
							class="absolute top-0 right-0 h-full w-16 bg-gradient-to-r from-lightroom-950/0 to-lightroom-950 flex items-center justify-center"
						>
							<div class="bg-lightroom-800 rounded-full p-2">
								<CopyIcon class="size-5" />
							</div>
						</div>
					</div>
				</div>
			</Tabs.Content>
			<Tabs.Content value="tab-ollama" class="h-full">
				<div class="h-64">
					<div class="h-fit relative overflow-hidden rounded-3xl">
						<Highlight language={bash} code={`brew install ollama`} />
						<div
							class="absolute top-0 right-0 h-full w-16 bg-gradient-to-r from-lightroom-950/0 to-lightroom-950 flex items-center justify-center"
						>
							<div class="bg-lightroom-800 rounded-full p-2">
								<CopyIcon class="size-5" />
							</div>
						</div>
					</div>
				</div>
			</Tabs.Content>
			<Tabs.Content value="tab-model" class="h-full">
				<div class="h-64">
					<div class="h-fit relative overflow-hidden rounded-3xl">
						<Highlight language={bash} code={`ollama run minicpm-v`} />
						<div
							class="absolute top-0 right-0 h-full w-16 bg-gradient-to-r from-lightroom-950/0 to-lightroom-950 flex items-center justify-center"
						>
							<div class="bg-lightroom-800 rounded-full p-2">
								<CopyIcon class="size-5" />
							</div>
						</div>
					</div>
				</div>
			</Tabs.Content>
		</Tabs.Root>
	</div>
</section>

<style lang="postcss">
	.hljs {
		@apply !h-full;
	}
</style>
