import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    allowedHosts: ["6ad9daaf-b74d-406e-80e3-b65039d161cd-00-1je4l2czhhgrt.spock.replit.dev"]
  }
})
