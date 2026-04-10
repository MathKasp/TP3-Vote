import { useState } from 'react'
import heroImg from './assets/hero.png'
import './App.css'

declare global {
  interface Window {
    ethereum?: {
      isMetaMask?: boolean
      request: (request: { method: string }) => Promise<string[]>
    }
  }
}

type User = {
  id: string
  name: string
  votes: number
}

const initialUsers: User[] = [
  { id: 'alice', name: 'Alice', votes: 2 },
  { id: 'bob', name: 'Bob', votes: 1 },
  { id: 'carol', name: 'Carol', votes: 0 },
  { id: 'david', name: 'David', votes: 0 },
]

function App() {
  const [users, setUsers] = useState<User[]>(initialUsers)
  const [currentUserId, setCurrentUserId] = useState(users[0].id)
  const [votes, setVotes] = useState<Record<string, string>>({})
  const [walletAddress, setWalletAddress] = useState('')
  const [walletInput, setWalletInput] = useState('')

  const currentVote = votes[currentUserId]

  const handleVote = (targetId: string) => {
    if (targetId === currentUserId || currentVote) return

    setUsers((prev) =>
      prev.map((user) =>
        user.id === targetId ? { ...user, votes: user.votes + 1 } : user,
      ),
    )
    setVotes((prev) => ({ ...prev, [currentUserId]: targetId }))
  }

  const handleResetVotes = () => {
    setUsers(initialUsers)
    setVotes({})
  }

  const handleConnectWallet = () => {
    const address = walletInput.trim()
    const isValidAddress = /^0x[a-fA-F0-9]{40}$/.test(address)

    if (!isValidAddress) {
      alert('Merci de saisir une adresse de wallet valide (0x... à 40 caractères).')
      return
    }

    setWalletAddress(address)
  }

  const handleDisconnectWallet = () => {
    setWalletAddress('')
    setWalletInput('')
  }

  return (
    <main className="app-shell">
      <header className="hero-section">
        <div className="hero">
          <img src={heroImg} className="base" width="170" height="179" alt="Icone vote" />
        </div>
        <div className="hero-copy">
          <h1>Interface de vote</h1>
          <p>Choisissez un utilisateur, puis votez pour un autre membre de la communauté.</p>
          <div className="wallet-connect">
            <p className="wallet-status">
              {walletAddress
                ? `Connecté : ${walletAddress.slice(0, 6)}...${walletAddress.slice(-4)}`
                : 'Entrez l’adresse de votre wallet pour vous connecter.'}
            </p>
            <input
              type="text"
              className="wallet-input"
              placeholder="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
              value={walletInput}
              onChange={(event) => setWalletInput(event.target.value)}
              disabled={Boolean(walletAddress)}
            />
            <div className="wallet-actions">
              <button
                type="button"
                className="connect-button"
                onClick={handleConnectWallet}
                disabled={Boolean(walletAddress)}
              >
                {walletAddress ? 'Portefeuille connecté' : 'Connecter l’adresse'}
              </button>
              <button
                type="button"
                className="disconnect-button"
                onClick={handleDisconnectWallet}
                disabled={!walletAddress}
              >
                Déconnecter
              </button>
            </div>
          </div>
        </div>
      </header>

      <section className="voting-panel">
        <div className="voter-select">
          <label htmlFor="current-user">Utilisateur connecté</label>
          <select
            id="current-user"
            value={currentUserId}
            onChange={(event) => setCurrentUserId(event.target.value)}
          >
            {users.map((user) => (
              <option key={user.id} value={user.id}>
                {user.name}
              </option>
            ))}
          </select>
        </div>

        <div className="status-card">
          <h2>État du vote</h2>
          <p>
            {currentVote
              ? `Vous avez voté pour ${users.find((user) => user.id === currentVote)?.name ?? 'cet utilisateur'}.`
              : 'Vous pouvez encore voter pour un autre utilisateur.'}
          </p>
          <button
            type="button"
            className="reset-button"
            onClick={handleResetVotes}
            disabled={Object.keys(votes).length === 0}
          >
            Réinitialiser les votes
          </button>
        </div>
      </section>

      <section className="user-grid">
        {users.map((user) => (
          <article key={user.id} className={`user-card ${user.id === currentUserId ? 'current' : ''}`}>
            <div className="user-card-header">
              <h3>{user.name}</h3>
              <span className="badge">
                {user.votes} vote{user.votes > 1 ? 's' : ''}
              </span>
            </div>
            <p className="user-role">{user.id === currentUserId ? 'Vous' : 'Membre'}</p>
            <button
              className="vote-button"
              onClick={() => handleVote(user.id)}
              disabled={user.id === currentUserId || Boolean(currentVote)}
            >
              {user.id === currentUserId ? 'Vous-même' : currentVote ? 'Vote terminé' : `Voter pour ${user.name}`}
            </button>
          </article>
        ))}
      </section>

      <section className="results-panel">
        <h2>Résumé des votes</h2>
        {Object.keys(votes).length > 0 ? (
          <ul>
            {Object.entries(votes).map(([voterId, targetId]) => (
              <li key={voterId}>
                {users.find((user) => user.id === voterId)?.name ?? voterId} a voté pour{' '}
                {users.find((user) => user.id === targetId)?.name ?? targetId}.
              </li>
            ))}
          </ul>
        ) : (
          <p>Aucun vote enregistré pour le moment.</p>
        )}
      </section>
    </main>
  )
}

export default App
