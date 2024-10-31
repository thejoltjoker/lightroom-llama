import type { Config } from 'tailwindcss';

export default {
	content: ['./src/**/*.{html,js,svelte,ts}'],

	theme: {
		extend: {
			fontFamily: {
				sans: ['Figtree Variable', 'Noto Color Emoji', 'sans-serif'],
				mono: ['JetBrains Mono Variable', 'Noto Color Emoji', 'monospace'],
				emoji: ['Noto Color Emoji', 'Noto Color Emoji', 'sans-serif']
			},
			colors: {
				lightroom: {
					'50': '#f5f5f6',
					'100': '#e6e6e7',
					'200': '#DADADA',
					'300': '#B9BAB9',
					'400': '#878789',
					'500': '#6c6c6e',
					'600': '#5d5c5e',
					'700': '#505051',
					'800': '#454545',
					'900': '#3c3c3d',
					'950': '#2E2E2E',
					green: '#58be5c'
				}
			}
		}
	},
	safelist: ['trigger'],
	plugins: [require('@tailwindcss/forms')]
} as Config;
