class NotificationManager {
    constructor() {
        this.container = document.getElementById('toast-container');
    }

    createToast(title, message) {
        const toast = document.createElement('div');
        toast.classList.add('toast');
        toast.setAttribute('role', 'alert');
        toast.setAttribute('aria-live', 'assertive');
        toast.setAttribute('aria-atomic', 'true');

        const toastHeader = document.createElement('div');
        toastHeader.classList.add('toast-header');

        const toastImg = document.createElement('i');
        toastImg.classList.add('bi', 'bi-chat-left-dots', 'm-1');
        toastImg.src = '...'; // Установите путь к изображению, если нужно
        toastImg.alt = '...'; // Установите альтернативный текст для изображения, если нужно

        const toastStrong = document.createElement('strong');
        toastStrong.classList.add('me-auto');
        toastStrong.textContent = title;

        const toastTime = document.createElement('small');
        toastTime.textContent = 'Сейчас'; // Установите время, если нужно

        const toastCloseButton = document.createElement('button');
        toastCloseButton.type = 'button';
        toastCloseButton.classList.add('btn-close');
        toastCloseButton.setAttribute('data-bs-dismiss', 'toast');
        toastCloseButton.setAttribute('aria-label', 'Закрыть');

        const toastBody = document.createElement('div');
        toastBody.classList.add('toast-body');
        toastBody.textContent = message;

        toastHeader.appendChild(toastImg);
        toastHeader.appendChild(toastStrong);
        toastHeader.appendChild(toastTime);
        toastHeader.appendChild(toastCloseButton);

        toast.appendChild(toastHeader);
        toast.appendChild(toastBody);

        return toast;
    }

    showToast(title, message) {
        const toast = this.createToast(title, message);
        this.container.appendChild(toast);

        const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toast);
        toastBootstrap.show();

        setTimeout(() => {
            toastBootstrap.hide();
        }, 5000);
    }
}


function Message(title, text) {
    const notifier = new NotificationManager();
    notifier.showToast(title, text);
}
