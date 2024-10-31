<script>
	import { Tabs } from 'bits-ui';
</script>

<section id="install">
	<div class="container">
		<h2 class="text-4xl font-bold">Improve your workflow</h2>
		<p class="max-w-md text-center">
			Unleash your llama on your photos by following these simple steps.
		</p>

		<Tabs.Root class="w-full h-full flex flex-col gap-6">
			<Tabs.List class="grid grid-cols-3 w-full font-medium gap-4 items-center justify-center">
				<Tabs.Trigger
					value="tab-download"
					class="px-4 py-2 rounded-full bg-transparent data-[state=active]:bg-white data-[state=active]:text-lightroom-950"
					>💾 Download</Tabs.Trigger
				>
				<Tabs.Trigger
					value="tab-install"
					class="px-4 py-2 rounded-full bg-transparent data-[state=active]:bg-white data-[state=active]:text-lightroom-950"
					>💽 Install</Tabs.Trigger
				>
				<Tabs.Trigger
					value="tab-run"
					class="px-4 py-2 rounded-full bg-transparent data-[state=active]:bg-white data-[state=active]:text-lightroom-950"
					>🚀 Run</Tabs.Trigger
				>
			</Tabs.List>
			<Tabs.Content value="tab-download">
				<div class="h-64 flex flex-col gap-4 items-center justify-center">
					<p>Download from GitHub.</p>
					<a
						href="https://github.com/thejoltjoker/lightroom-llama/archive/refs/heads/main.zip"
						class="button">Download</a
					>
					<!-- TODO Get url and version from releases -->
					<p class="text-lightroom-400">Current version: 0.1.0</p>
				</div>
			</Tabs.Content>
			<Tabs.Content value="tab-install" class="h-64">
				<div class="h-64 flex flex-col gap-4 items-center justify-center">
					<p>Instructions coming soon.</p>
				</div>
			</Tabs.Content>
			<Tabs.Content value="tab-run" class="h-64">
				<div class="h-64 flex flex-col gap-4 items-center justify-center">
					<p>Instructions coming soon.</p>
				</div>
			</Tabs.Content>
		</Tabs.Root>
	</div>
</section>
