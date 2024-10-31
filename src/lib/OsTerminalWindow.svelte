<script lang="ts">
	import OsWindow from './OsWindow.svelte';

	import Highlight from 'svelte-highlight';
	import type { LanguageType } from 'svelte-highlight/languages';
	import typescript from 'svelte-highlight/languages/typescript';
	import { atomOneDark } from 'svelte-highlight/styles';

	export let code: string;
	export let language: LanguageType<string> = typescript;
</script>

<svelte:head>
	{@html atomOneDark}
</svelte:head>

<OsWindow>
	<div class="h-full w-full bg-lightroom-950 font-mono text-left select-text hljs">
		<Highlight {language} {code} class="p-4 w-full h-full" />
	</div>
</OsWindow>
