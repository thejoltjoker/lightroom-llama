<script lang="ts">
	import { Tabs } from 'bits-ui';
	import Highlight from 'svelte-highlight';
	import { bash } from 'svelte-highlight/languages';
	import { atomOneDark } from 'svelte-highlight/styles';
</script>

<svelte:head>
	{@html atomOneDark}
</svelte:head>
<section class="bg-lightroom-900 text-white h-[80vh] flex items-center">
	<div class="container text-center flex flex-col gap-4 justify-center items-center">
		<h2 class="text-4xl font-bold">Breed your llama</h2>
		<p class="max-w-md">
			Open a terminal and follow these simple steps to get started with ollama.
		</p>

		<Tabs.Root class="w-full h-full flex flex-col gap-6">
			<Tabs.List class="grid grid-cols-3 w-full font-medium gap-4 items-center justify-center">
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
			<Tabs.Content value="tab-homebrew" class="h-full">
				<Highlight
					language={bash}
					code={`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`}
					class="h-64 rounded-xl overflow-hidden"
				/>
			</Tabs.Content>
			<Tabs.Content value="tab-ollama" class="h-full">
				<Highlight
					language={bash}
					code={`brew install ollama`}
					class="h-64 rounded-xl overflow-hidden text-left"
				/>
			</Tabs.Content>
			<Tabs.Content value="tab-model" class="h-full">
				<Highlight
					language={bash}
					code={`ollama run minicpm-v`}
					class="h-64 rounded-xl overflow-hidden text-left"
				/>
			</Tabs.Content>
		</Tabs.Root>
	</div>
</section>

<style lang="postcss">
	.hljs {
		@apply !h-full;
	}
</style>
