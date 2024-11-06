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
			<Tabs.List
				class="grid grid-cols-3 w-full font-medium gap-6 items-center justify-center bg-lightroom-200 rounded-full p-2 relative text-lightroom-950"
			>
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
				<div
					class="min-h-80 flex flex-col gap-4 items-center justify-center bg-lightroom-200 rounded-3xl"
				>
					<p class="text-lightroom-950 font-bold text-2xl">Download from GitHub.</p>

					<a
						href={'https://github.com/thejoltjoker/lightroom-llama/archive/refs/heads/main.zip'}
						class="button">Download</a
					>

					<!-- TODO Get url and version from releases -->
					<div class="inline-flex gap-2 items-center">
						<p class="text-lightroom-400 font-mono text-sm font-light">v0.1.1</p>
						<span class="pill">beta</span>
					</div>
				</div>
			</Tabs.Content>
			<Tabs.Content value="tab-install">
				<div
					class="min-h-80 flex flex-col gap-4 items-center justify-center bg-lightroom-200 rounded-3xl"
				>
					<p class="text-lightroom-950 font-bold text-2xl">Install the plugin in Lightroom.</p>
					<div class="font-sans inline-flex gap-2 items-center">
						<p>
							Go to <span class="bg-lightroom-100 font-mono p-2 rounded-lg"
								>File > Plug-in Manager...</span
							>
						</p>
						<!-- <div class="inline-flex gap-2 items-center"> -->
						<p>or press</p>
						<span class="bg-white rounded-lg shadow-md flex items-center justify-center size-8"
							>⌥</span
						>+<span class="bg-white rounded-lg shadow-md flex items-center justify-center size-8"
							>⇧</span
						>+<span class="bg-white rounded-lg shadow-md flex items-center justify-center size-8"
							>⌘</span
						>+<span class="bg-white rounded-lg shadow-md flex items-center justify-center size-8"
							>,</span
						>
						<!-- </div> -->
					</div>
					<p>
						Press <span class="bg-lightroom-100 shadow-md p-2 rounded-lg">Add</span> and browse to your
						download folder.
					</p>
					<p>
						Select <span class="bg-lightroom-100 font-mono p-2 rounded-lg">
							<span class="font-emoji">📂</span>lightroom-llama.lrplugin
						</span> and click Open.
					</p>

					<!-- <div class="bg-lightroom-100 rounded-xl p-4">
						<span class="font-emoji">📂</span><span class="text-lightroom-700 font-mono">
							~/Library/Application Support/Adobe/Lightroom/Modules
						</span>
					</div> -->
				</div>
			</Tabs.Content>
			<Tabs.Content value="tab-run">
				<div
					class="min-h-80 flex flex-col gap-4 items-center justify-center bg-lightroom-200 rounded-3xl"
				>
					<p class="text-lightroom-950 font-bold text-2xl">Run the plugin.</p>
					<p>Select the photo you want to show to your llama.</p>

					<p>
						Go to <span class="bg-lightroom-100 font-mono p-2 rounded-lg"
							>Library > Plug-in Extras > Lightroom Llama</span
						>
					</p>

					<p>
						Click <span class="bg-lightroom-100 font-mono p-2 rounded-lg shadow-md">
							Generate
						</span>
						and then
						<span class="bg-lightroom-100 font-mono p-2 rounded-lg shadow-md"> Save </span> if you're
						satisfied.
					</p>

					<!-- <div class="bg-lightroom-100 rounded-xl p-4">
						<span class="font-emoji">📂</span><span class="text-lightroom-700 font-mono">
							~/Library/Application Support/Adobe/Lightroom/Modules
						</span>
					</div> -->
				</div>
			</Tabs.Content>
		</Tabs.Root>
	</div>
</section>
