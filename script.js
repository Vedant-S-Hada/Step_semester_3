const menuBtn = document.querySelector(".menu-btn");
const navLinks = document.querySelector(".nav-links");
const yearEl = document.getElementById("year");
const revealEls = document.querySelectorAll(".reveal");

if (yearEl) {
  yearEl.textContent = String(new Date().getFullYear());
}

if (menuBtn && navLinks) {
  menuBtn.addEventListener("click", () => {
    const expanded = menuBtn.getAttribute("aria-expanded") === "true";
    menuBtn.setAttribute("aria-expanded", String(!expanded));
    navLinks.classList.toggle("open");
  });
}

const observer = new IntersectionObserver(
  entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add("show");
        observer.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.12 }
);

revealEls.forEach(el => observer.observe(el));
