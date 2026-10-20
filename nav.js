/* Kevin Sanjuan — Navegación y footer compartidos (se editan SOLO acá, valen para todas las páginas) */
(function () {
  var root = document.body.dataset.root || ''
  var page = document.body.dataset.page || 'inicio'

  var links = [
    { id: 'inicio', label: 'Inicio', href: root + 'index.html#inicio' },
    { id: 'branding', label: 'Marca & Branding', href: root + 'branding.html' },
    { id: 'fotos', label: 'Fotografía', href: root + 'fotos.html' },
    { id: 'about', label: 'Sobre mí', href: root + 'index.html#about' },
    { id: 'contacto', label: 'Contacto', href: root + 'index.html#contacto' }
  ]

  var socials = [
    { label: 'Instagram', href: 'https://instagram.com' },
    { label: 'Behance', href: 'https://behance.net' },
    { label: 'YouTube', href: 'https://youtube.com' }
  ]

  var header = document.createElement('header')
  header.className = 'navbar'
  header.innerHTML =
    '<a href="' + root + 'index.html#inicio" class="navbar-logo">Kevin Sanjuan</a>' +
    '<nav class="navbar-links" aria-label="Secciones">' +
    links.map(function (l) {
      return '<a href="' + l.href + '"' + (l.id === page ? ' class="active"' : '') + '>' + l.label + '</a>'
    }).join('') +
    '</nav>' +
    '<button id="menu-toggle" class="menu-toggle" aria-label="Abrir menú" aria-expanded="false" aria-controls="menu-overlay">' +
    '<span class="menu-label">Menú</span>' +
    '<span class="menu-icon" aria-hidden="true"><span></span><span></span></span>' +
    '</button>'

  var overlay = document.createElement('nav')
  overlay.id = 'menu-overlay'
  overlay.className = 'overlay'
  overlay.setAttribute('aria-label', 'Navegación principal')
  overlay.setAttribute('aria-hidden', 'true')
  overlay.innerHTML =
    '<ul class="overlay-links">' +
    links.map(function (l, i) {
      return '<li><a href="' + l.href + '" style="--i:' + i + '"><span>0' + (i + 1) + '</span>' + l.label + '</a></li>'
    }).join('') +
    '</ul>' +
    '<div class="overlay-footer">' +
    '<span>Santa Marta, Magdalena</span>' +
    socials.map(function (s) {
      return '<a href="' + s.href + '" target="_blank" rel="noopener noreferrer">' + s.label + '</a>'
    }).join('') +
    '<a href="mailto:hola@kevinsanjuan.com">Email</a>' +
    '</div>'

  var clients = [
    { name: 'Norte', src: 'images/clientes/norte.svg' },
    { name: 'Áurea', src: 'images/clientes/aurea.svg' },
    { name: 'Casa Mar', src: 'images/clientes/casa-mar.svg' },
    { name: 'Vértice', src: 'images/clientes/vertice.svg' },
    { name: 'Lumen', src: 'images/clientes/lumen.svg' },
    { name: 'Origen', src: 'images/clientes/origen.svg' }
  ]

  var footer = document.createElement('footer')
  footer.className = 'footer'
  footer.innerHTML =
    '<section class="footer-clients">' +
    '<h2 class="footer-clients-title">Marcas con las que he trabajado</h2>' +
    '<div class="footer-clients-row">' +
    clients.map(function (c) {
      return '<img src="' + root + c.src + '" alt="' + c.name + '" width="160" height="40" loading="lazy">'
    }).join('') +
    '</div>' +
    '</section>' +
    '<div class="footer-bottom">' +
    '<p>© <span id="year"></span> Kevin Sanjuan · Santa Marta, Magdalena</p>' +
    '<div>' +
    socials.map(function (s) {
      return '<a href="' + s.href + '" target="_blank" rel="noopener noreferrer">' + s.label + '</a>'
    }).join('') +
    '</div>' +
    '</div>'

  document.body.insertBefore(header, document.body.firstChild)
  document.body.appendChild(overlay)
  document.body.appendChild(footer)
  document.getElementById('year').textContent = new Date().getFullYear()

  /* Menú overlay */
  var toggle = document.getElementById('menu-toggle')
  var firstLink = overlay.querySelector('a')

  function setMenu(open) {
    overlay.classList.toggle('open', open)
    overlay.setAttribute('aria-hidden', String(!open))
    toggle.classList.toggle('open', open)
    toggle.setAttribute('aria-expanded', String(open))
    toggle.setAttribute('aria-label', open ? 'Cerrar menú' : 'Abrir menú')
    document.body.classList.toggle('no-scroll', open)
    if (open && firstLink) firstLink.focus()
  }

  toggle.addEventListener('click', function () {
    setMenu(!overlay.classList.contains('open'))
  })

  overlay.querySelectorAll('a').forEach(function (link) {
    link.addEventListener('click', function () { setMenu(false) })
  })

  window.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && overlay.classList.contains('open')) {
      setMenu(false)
      toggle.focus()
    }
  })

  /* Si el menú queda abierto y se pasa a escritorio, el botón desaparece: se cierra solo */
  window.matchMedia('(min-width: 768px)').addEventListener('change', function (e) {
    if (e.matches && overlay.classList.contains('open')) setMenu(false)
  })
})()
