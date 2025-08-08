// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// FAQ Toggle functionality
window.toggleFAQ = function(faqId) {
  const content = document.getElementById(faqId + '-content');
  const icon = document.getElementById(faqId + '-icon');
  
  if (content.classList.contains('hidden')) {
    content.classList.remove('hidden');
    icon.style.transform = 'rotate(180deg)';
  } else {
    content.classList.add('hidden');
    icon.style.transform = 'rotate(0deg)';
  }
}

// Smooth scrolling for anchor links
document.addEventListener('DOMContentLoaded', function() {
  // Add smooth scrolling to all anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });
});

// Add CSS for smooth scrolling to the document
document.addEventListener('DOMContentLoaded', function() {
  if (!document.querySelector('style[data-smooth-scroll]')) {
    const style = document.createElement('style');
    style.setAttribute('data-smooth-scroll', 'true');
    style.textContent = `
      html {
        scroll-behavior: smooth;
      }
    `;
    document.head.appendChild(style);
  }
});

import "trix"
import "@rails/actiontext"
