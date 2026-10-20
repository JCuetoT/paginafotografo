/* Kevin Sanjuan — JavaScript puro (sin dependencias) */

/* ---------- Navbar: fondo al scrollear ---------- */
var navbar = document.querySelector('.navbar')

function onScroll() {
  navbar.classList.toggle('scrolled', window.scrollY > 40)
}

window.addEventListener('scroll', onScroll, { passive: true })
onScroll()

/* ---------- Scrollspy (solo en index) ---------- */
if (document.body.dataset.spy === 'sections') {
  var spySections = document.querySelectorAll('section[id]')
  var navLinks = document.querySelectorAll('.navbar-links a[href^="#"]')

  var spyObserver = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          navLinks.forEach(function (link) {
            link.classList.toggle('active', link.getAttribute('href') === '#' + entry.target.id)
          })
        }
      })
    },
    { rootMargin: '-40% 0px -55% 0px' }
  )

  spySections.forEach(function (section) { spyObserver.observe(section) })
}

/* ---------- Botón magnético (física tipo spring) ---------- */
document.querySelectorAll('.magnetic').forEach(function (el) {
  var strength = parseFloat(el.dataset.strength || '0.35')
  var raf = null
  var target = { x: 0, y: 0 }
  var current = { x: 0, y: 0 }

  function loop() {
    current.x += (target.x - current.x) * 0.18
    current.y += (target.y - current.y) * 0.18
    el.style.transform = 'translate3d(' + current.x.toFixed(2) + 'px, ' + current.y.toFixed(2) + 'px, 0)'
    if (Math.abs(target.x - current.x) > 0.4 || Math.abs(target.y - current.y) > 0.4) {
      raf = requestAnimationFrame(loop)
    } else {
      el.style.transform = 'translate3d(0, 0, 0)'
      raf = null
    }
  }

  el.addEventListener('mousemove', function (e) {
    var rect = el.getBoundingClientRect()
    target.x = (e.clientX - (rect.left + rect.width / 2)) * strength
    target.y = (e.clientY - (rect.top + rect.height / 2)) * strength
    if (!raf) raf = requestAnimationFrame(loop)
  })

  el.addEventListener('mouseleave', function () {
    target.x = 0
    target.y = 0
  })
})

/* ---------- Reveals al hacer scroll ---------- */
var revealObserver = new IntersectionObserver(
  function (entries) {
    entries.forEach(function (entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible')
        revealObserver.unobserve(entry.target)
      }
    })
  },
  { threshold: 0.15, rootMargin: '0px 0px -10% 0px' }
)

document.querySelectorAll('.reveal').forEach(function (el) { revealObserver.observe(el) })

/* ---------- Slideshow automático (las fotos cambian solas) ---------- */
document.querySelectorAll('[data-slideshow]').forEach(function (box) {
  var imgs = box.querySelectorAll('.slideshow-img')
  if (imgs.length < 2) return

  /* Los puntos se generan solos: siempre hay uno por foto */
  var dotBox = box.querySelector('.showcase-dots')
  if (dotBox) {
    dotBox.innerHTML = ''
    for (var d = 0; d < imgs.length; d++) {
      var dot = document.createElement('span')
      dot.className = 'slideshow-dot'
      dotBox.appendChild(dot)
    }
  }
  var dots = box.querySelectorAll('.slideshow-dot')

  var i = 0
  imgs[i].classList.add('active')
  if (dots.length) dots[i].classList.add('active')

  setInterval(function () {
    imgs[i].classList.remove('active')
    if (dots.length) dots[i].classList.remove('active')
    i = (i + 1) % imgs.length
    imgs[i].classList.add('active')
    if (dots.length) dots[i].classList.add('active')
  }, 4000)
})

/* ---------- Lightbox (galería grande al hacer clic) ---------- */
var galleryItems = document.querySelectorAll('.gallery-item')
if (galleryItems.length) {
  var lightbox = document.createElement('div')
  lightbox.className = 'lightbox'
  lightbox.setAttribute('role', 'dialog')
  lightbox.setAttribute('aria-label', 'Vista ampliada de la foto')
  lightbox.innerHTML =
    '<img alt="" class="lightbox-img">' +
    '<button type="button" class="lightbox-btn lightbox-prev" aria-label="Foto anterior">‹</button>' +
    '<button type="button" class="lightbox-btn lightbox-next" aria-label="Foto siguiente">›</button>' +
    '<button type="button" class="lightbox-btn lightbox-close" aria-label="Cerrar">×</button>'
  document.body.appendChild(lightbox)

  var lightboxImg = lightbox.querySelector('.lightbox-img')
  var current = 0

  function open(idx) {
    current = idx
    update()
    lightbox.classList.add('open')
    document.body.classList.add('no-scroll')
  }

  function close() {
    lightbox.classList.remove('open')
    document.body.classList.remove('no-scroll')
  }

  function update() {
    var item = galleryItems[current]
    var img = item.querySelector('img')
    lightboxImg.src = img.currentSrc || img.src
    lightboxImg.alt = img.alt || ''
  }

  function step(dir) {
    current = (current + dir + galleryItems.length) % galleryItems.length
    update()
  }

  galleryItems.forEach(function (item, idx) {
    item.addEventListener('click', function (e) {
      e.preventDefault()
      open(idx)
    })
    item.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); open(idx) }
    })
  })

  lightbox.querySelector('.lightbox-close').addEventListener('click', close)
  lightbox.querySelector('.lightbox-prev').addEventListener('click', function () { step(-1) })
  lightbox.querySelector('.lightbox-next').addEventListener('click', function () { step(1) })

  lightbox.addEventListener('click', function (e) {
    if (e.target === lightbox) close()
  })

  window.addEventListener('keydown', function (e) {
    if (!lightbox.classList.contains('open')) return
    if (e.key === 'Escape') close()
    if (e.key === 'ArrowLeft') step(-1)
    if (e.key === 'ArrowRight') step(1)
  })
}

/* ---------- Formulario de contacto (mailto) ---------- */
var form = document.getElementById('contact-form')
if (form) {
  var success = document.getElementById('form-success')

  form.addEventListener('submit', function (e) {
    e.preventDefault()
    var email = form.dataset.email
    var subject = encodeURIComponent('Encargo — ' + form.name.value)
    var body = encodeURIComponent(
      'Nombre: ' + form.name.value + '\n' +
      'Email: ' + form.email.value + '\n\n' +
      form.message.value
    )
    window.location.href = 'mailto:' + email + '?subject=' + subject + '&body=' + body
    form.hidden = true
    success.hidden = false
  })
}

/* ---------- Imágenes: sin menú contextual ni arrastre ---------- */
/* Es fricción, no seguridad: una foto ya descargada al navegador siempre se
   puede recuperar. La protección real va en el hosting y en el peso del archivo. */
document.addEventListener('contextmenu', function (e) {
  if (e.target.tagName === 'IMG') e.preventDefault()
})

document.addEventListener('dragstart', function (e) {
  if (e.target.tagName === 'IMG') e.preventDefault()
})

document.querySelectorAll('img').forEach(function (img) {
  img.draggable = false
})
