import type { Config } from 'tailwindcss';

export default {
	content: ['./src/**/*.{html,js,svelte,ts}'],

	theme: {
		extend: {
			fontFamily: {
				sans: ['Noto Color Emoji', 'Figtree Variable', 'sans-serif'],
				mono: ['Noto Color Emoji', 'JetBrains Mono Variable', 'monospace'],
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

	plugins: [require('@tailwindcss/forms')]
} as Config;
