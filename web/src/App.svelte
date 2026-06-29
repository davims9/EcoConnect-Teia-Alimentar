<script lang="ts">
  const iframeSrc = '/flutter-app/index.html'
</script>

<div class="page">
  <div class="particles">
    {#each Array(20) as _, i}
      <div class="particle" style="--i: {i}; --x: {Math.random() * 100}%; --d: {0.5 + Math.random() * 1.5}s; --s: {2 + Math.random() * 3}px;"></div>
    {/each}
  </div>

  <div class="hero">
    <div class="hero-content">
      <div class="emblem"></div>
      <h1 class="title">ECOCONNECT</h1>
      <h2 class="subtitle-main">TEIA ALIMENTAR</h2>
      <p class="desc">
        Construa teias alimentares e descubra os ecossistemas!
      </p>
    </div>
  </div>

  <div class="main">
    <div class="game-container">
      <iframe
        class="game-iframe"
        src={iframeSrc}
        title="EcoConnect App"
        allow="camera; microphone; autoplay"
      ></iframe>
    </div>
  </div>
</div>

<style>
  .page {
    min-height: 100vh;
    min-height: 100dvh;
    background: linear-gradient(180deg, #0A1F14 0%, #0D2B1A 33%, #123B22 66%, #164A2A 100%);
    display: flex;
    flex-direction: column;
    font-family: 'Inter', system-ui, -apple-system, sans-serif;
    position: relative;
    overflow: hidden;
  }

  .particles {
    position: fixed;
    inset: 0;
    pointer-events: none;
    z-index: 0;
    overflow: hidden;
  }

  .particle {
    position: absolute;
    bottom: -10px;
    left: var(--x);
    width: var(--s);
    height: var(--s);
    border-radius: 50%;
    background: rgba(129, 199, 132, 0.3);
    animation: float-up var(--d) ease-in-out infinite alternate;
    animation-delay: calc(var(--i) * 0.15s);
  }

  @keyframes float-up {
    0% { transform: translateY(0) scale(0.5); opacity: 0; }
    50% { opacity: 0.5; }
    100% { transform: translateY(-100vh) scale(1); opacity: 0; }
  }

  .hero {
    position: relative;
    z-index: 1;
    text-align: center;
    padding: 32px 24px 12px;
    flex-shrink: 0;
  }

  .hero-content {
    max-width: 640px;
    margin: 0 auto;
  }

  .emblem {
    width: 72px;
    height: 72px;
    border-radius: 50%;
    border: 3px solid rgba(76, 175, 80, 0.6);
    margin: 0 auto 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    box-shadow:
      0 0 24px 4px rgba(76, 175, 80, 0.3),
      0 0 48px 8px rgba(76, 175, 80, 0.15);
  }

  .emblem::after {
    content: '🌿';
    font-size: 32px;
    filter: brightness(0) saturate(100%) invert(76%) sepia(38%) saturate(542%) hue-rotate(80deg) brightness(95%) contrast(85%);
  }

  .title {
    font-size: 2rem;
    font-weight: 900;
    letter-spacing: 6px;
    color: #E8F5E9;
    margin: 0;
    line-height: 1.15;
    text-shadow:
      0 0 20px rgba(76, 175, 80, 0.5),
      0 3px 8px rgba(27, 94, 32, 0.8);
  }

  .subtitle-main {
    font-size: 0.9rem;
    font-weight: 600;
    letter-spacing: 8px;
    color: #A5D6A7;
    margin: 8px 0 0;
    text-shadow: 0 0 12px rgba(0, 0, 0, 0.4);
  }

  .desc {
    font-size: 0.8rem;
    color: rgba(129, 199, 132, 0.7);
    margin: 8px 0 0;
    line-height: 1.5;
  }

  .main {
    position: relative;
    z-index: 1;
    flex: 1;
    display: flex;
    padding: 8px 24px 24px;
    min-height: 0;
  }

  .game-container {
    flex: 1;
    max-width: 1200px;
    margin: 0 auto;
    width: 100%;
    background: rgba(26, 58, 36, 0.5);
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid rgba(46, 125, 50, 0.3);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3);
  }

  .game-iframe {
    width: 100%;
    height: 100%;
    border: none;
    display: block;
    background: transparent;
  }

  @media (max-width: 640px) {
    .hero { padding: 24px 16px 8px; }
    .emblem { width: 60px; height: 60px; }
    .emblem::after { font-size: 26px; }
    .title { font-size: 1.5rem; letter-spacing: 4px; }
    .subtitle-main { font-size: 0.75rem; letter-spacing: 5px; }
    .desc { font-size: 0.72rem; }
    .main { padding: 4px 12px 16px; }
    .game-container { border-radius: 10px; }
  }

  @media (min-width: 1200px) {
    .title { font-size: 2.4rem; letter-spacing: 8px; }
    .emblem { width: 90px; height: 90px; }
    .emblem::after { font-size: 40px; }
  }
</style>
