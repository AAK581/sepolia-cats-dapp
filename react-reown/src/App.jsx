import { createAppKit } from '@reown/appkit/react';
import { WagmiProvider, useReadContract, useWriteContract, useAccount } from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi';
import { scrollSepolia } from '@reown/appkit/networks';
import { ThemeProvider, createTheme, Box, Switch } from '@mui/material';
import CssBaseline from '@mui/material/CssBaseline';
import { useState, useEffect } from 'react';
import { styled } from '@mui/material/styles';
import FormGroup from '@mui/material/FormGroup';
import FormControlLabel from '@mui/material/FormControlLabel';
import {Helmet} from 'react-helmet-async';
import './App.css';

// Setup queryClient
const queryClient = new QueryClient();

// Get projectId
const projectId = '95d3d7772ebc87055f7badf9115d9ae7';

// Metadata
const metadata = {
  name: 'GameDApp',
  description: 'Sepolia Cats dApp',
  url: 'https://blokkat-arabicblockchain-developer.vercel.app/',
  icons: ['https://avatars.githubusercontent.com/u/179229932'],
};

// Networks
const networks = [scrollSepolia];

// Create Wagmi Adapter
const wagmiAdapter = new WagmiAdapter({
  networks,
  projectId,
  ssr: true,
});

// Create modal (moved outside useEffect)
createAppKit({
  adapters: [wagmiAdapter],
  networks,
  projectId,
  metadata,
  features: { analytics: true },
});

// Contract configuration
const contractAddress = '0xEDDe9fc8ca8668046f9EAf9b64FDc94620518E26';
const contractAbi = [
  { type: 'function', name: 'getKittens', inputs: [], outputs: [{ name: '', type: 'uint256' }], stateMutability: 'view' },
  { type: 'function', name: 'rewardUser', inputs: [], outputs: [], stateMutability: 'nonpayable' },
  { type: 'function', name: 'totalKittens', inputs: [], outputs: [{ name: '', type: 'uint256' }], stateMutability: 'view' },
];

// Styled Switch
const MaterialUISwitch = styled(Switch)(({ theme }) => ({
  width: 62,
  height: 34,
  padding: 7,
  '& .MuiSwitch-switchBase': {
    margin: 1,
    padding: 0,
    transform: 'translateX(6px)',
    transition: 'transform 0.3s ease-in-out',
    '&.Mui-checked': {
      color: '#fff',
      transform: 'translateX(22px)',
      '& .MuiSwitch-thumb:before': {
        backgroundImage: `url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path fill="${encodeURIComponent(
          '#fff'
        )}" d="M4.2 2.5l-.7 1.8-1.8.7 1.8.7.7 1.8.6-1.8L6.7 5l-1.9-.7-.6-1.8zm15 8.3a6.7 6.7 0 11-6.6-6.6 5.8 5.8 0 006.6 6.6z"/></svg>')`,
      },
      '& + .MuiSwitch-track': {
        opacity: 1,
        backgroundColor: '#aab4be',
        ...theme.applyStyles('dark', { backgroundColor: '#8796A5' }),
      },
    },
  },
  '& .MuiSwitch-thumb': {
    backgroundColor: '#001e3c',
    width: 32,
    height: 32,
    transition: 'background-color 0.3s ease-in-out',
    '&::before': {
      content: "''",
      position: 'absolute',
      width: '100%',
      height: '100%',
      left: 0,
      top: 0,
      backgroundRepeat: 'no-repeat',
      backgroundPosition: 'center',
      backgroundImage: `url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20"><path fill="${encodeURIComponent(
        '#fff'
      )}" d="M9.305 1.667V3.75h1.389V1.667h-1.39zm-4.707 1.95l-.982.982L5.09 6.072l.982-.982-1.473-1.473zm10.802 0L13.927 5.09l.982.982 1.473-1.473-.982-.982zM10 5.139a4.872 4.872 0 00-4.862 4.86A4.872 4.872 0 0010 14.862 4.872 4.872 0 0014.86 10 4.872 4.872 0 0010 5.139zm0 1.389A3.462 3.462 0 0113.471 10a3.462 3.462 0 01-3.473 3.472A3.462 3.462 0 016.527 10 3.462 3.462 0 0110 6.528zM1.665 9.305v1.39h2.083v-1.39H1.666zm14.583 0v1.39h2.084v-1.39h-2.084zM5.09 13.928L3.616 15.4l.982.982 1.473-1.473-.982-.982zm9.82 0l-.982.982 1.473 1.473.982-.982-1.473-1.473zM9.305 16.25v2.083h1.389V16.25h-1.39z"/></svg>')`,
    },
    ...theme.applyStyles('dark', { backgroundColor: '#003892' }),
  },
  '& .MuiSwitch-track': {
    opacity: 1,
    backgroundColor: '#aab4be',
    borderRadius: 20 / 2,
    transition: 'background-color 0.3s ease-in-out',
    ...theme.applyStyles('dark', { backgroundColor: '#8796A5' }),
  },
}));

// AppKitProvider Component
function AppKitProvider({ mode, setMode }) {
  const { address, isConnected, isConnecting } = useAccount();

  // Get kittens from contract
  const { data: kittenCount, error: readError, isLoading } = useReadContract({
    address: contractAddress,
    abi: contractAbi,
    functionName: 'getKittens',
    account: address,
    chainId: 534351,
    enabled: isConnected && !!address,
    refetchInterval: 10000,
  });

  // Get total kittens from contract
  const { data: totalKittens, error: readError1, isLoading1 } = useReadContract({
    address: contractAddress,
    abi: contractAbi,
    functionName: 'totalKittens',
    enabled: isConnected,
    refetchInterval: 10000,
  });

  // Claim rewards from the contract
  const { writeContract, isPending, error: writeError } = useWriteContract();

  const claimRewards = () => {
    writeContract({
      address: contractAddress,
      abi: contractAbi,
      functionName: 'rewardUser',
      gas: 200000,
    });
  };

  // Show loading state until connection state is resolved
  if (isConnecting) {
    return (
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          bgcolor: 'background.default',
          color: 'text.primary',
          p: 3,
          minHeight: '90.9vh',
        }}
      >
        <p>Loading...</p>
      </Box>
    );
  }

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        bgcolor: 'background.default',
        color: 'text.primary',
        p: 3,
        minHeight: '100vh',
      }}
    >

      <Helmet>
        <title>Sepolia Cats dApp</title>
        <meta property="og:title" content="Sepolia Cats dApp"/>
        <meta property="og:description" content="A gamified Scroll Sepolia ETH faucet dApp"/>
        <meta property="og:image" content="sepoliaCatsCover"/>
        <meta property="og:url" content="https://blokkat-arabicblockchain-developer.vercel.app/"/>
        <meta property="og:type" content="website"/>
      </Helmet>

      <a href="https://rpg-game-sepolia-cats.vercel.app/" target="_blank" rel="noopener noreferrer">
        <img src="/oiia.png" alt="accessGameImg" className="accessGameImg" />
      </a>
      <p className="pPlay">
        Play the game <a href="https://rpg-game-sepolia-cats.vercel.app/" target="_blank" rel="noopener noreferrer">here</a>!
      </p>
      <div className="containerDiv" sx={[
        (theme) => ({
          backgroundColor: '#e1e5e9',
        }),
        (theme) =>
          theme.applyStyles('dark', {
            backgroundColor: theme.palette.secondary.main,
          }),
      ]}>
        <h1 className="app-title">Sepolia Cats dApp</h1>
        <FormGroup>
          <FormControlLabel
            control={
              <MaterialUISwitch
                sx={{ m: 1, position: 'absolute', top: '1rem', right: '1rem' }}
                checked={mode === 'dark'}
                onChange={() => setMode(mode === 'dark' ? 'light' : 'dark')}
              />
            }
          />
        </FormGroup>
        {!isConnected ? (
          <div className="w3div">
            <w3m-button className="connectButton" />
          </div>
        ) : (
          <>
            <p className="app-text">Wallet: {address?.slice(0, 6)}...{address?.slice(-4)}</p>
            <p className="app-text">On-Chain Kittens: {isLoading ? 'Loading...' : kittenCount ? Number(kittenCount) : '0'}</p>
            <p className="app-text">
              Total Kittens Collected By Players: {isLoading1 ? 'Loading...' : !totalKittens ? 0 : Number(totalKittens)}
            </p>
            {readError && <p className="app-error">Error: {readError.message}</p>}
            {readError1 && <p className="app-error">Error: {readError1.message}</p>}
            <button className="app-button" onClick={claimRewards} disabled={isPending}>
              {isPending ? 'Claiming...' : 'Claim Rewards'}
            </button>
            {writeError && <p className="app-error">Error: {writeError.message}</p>}
          </>
        )}
        <p className="app-textRequest">If you have Scroll Sepolia ETH that you don't need, please donate to this address</p>
        <p>0xB6B9B1a2E68F4ac770D5850735D055D6a2207374</p>
        <b><p className="app-textEligible">Donations above 200 SETH will be eligible for advertisement!!</p></b>
        <i><p className="disclaimer">No gambling or NSFW advertisements allowed</p></i>
      </div>
      <img className="app-sepImg" src="/sepoliaSuit1.png" useMap="#image-map" alt="Sepolia Cats Mascot" />
      <footer className="footerName">Made by Adham Ahmed Kamel</footer>
      <footer className="footerLinks">
        <a href="https://www.linkedin.com/in/adham-ahmad-3849b324b/" target="_blank" rel="noopener noreferrer">LinkedIn</a> - 
        <a href="https://github.com/AAK581" target="_blank" rel="noopener noreferrer"> Github</a>
      </footer>
    </Box>
  );
}

export default function App() {
  const [mode, setMode] = useState('light');
  const theme = createTheme({
    palette: { mode },
    transitions: { duration: { standard: 300 } },
  });

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <WagmiProvider config={wagmiAdapter.wagmiConfig}>
        <QueryClientProvider client={queryClient}>
          <AppKitProvider mode={mode} setMode={setMode} />
        </QueryClientProvider>
      </WagmiProvider>
    </ThemeProvider>
  );
}