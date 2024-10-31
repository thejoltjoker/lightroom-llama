<script lang="ts">
	export let title: string = 'Window Title';
</script>

<div
	class="bg-gray-100 rounded-lg shadow-xl border border-[#C6C6C6]/80 overflow-hidden w-full select-none h-full flex flex-col"
>
	<!-- Window title bar -->
	<div class="bg-[#F5F6F8] px-4 py-2 flex items-center border-b border-[#C6C6C6] relative">
		<!-- Traffic light buttons -->
		<div class="flex space-x-2 absolute left-3 top-1/2 -translate-y-1/2">
			<div class="w-3 h-3 rounded-full bg-[#FF5F57]"></div>
			<div class="w-3 h-3 rounded-full bg-[#FEBC2E]"></div>
			<div class="w-3 h-3 rounded-full bg-[#28C840]"></div>
		</div>
		<!-- Window title -->
		<div class="flex-1 text-center text-sm text-gray-600 font-medium">{title}</div>
	</div>
	<!-- Window content -->
	<div class="bg-[#ECECEC] grow">
		<slot />
	</div>
</div>
