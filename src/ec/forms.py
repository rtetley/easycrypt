from django import forms
from django.core.urlresolvers import reverse
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.utils.translation import ugettext_lazy as _
from crispy_forms.helper import FormHelper
from crispy_forms.layout import Submit


class RegisterForm(UserCreationForm):
    username = forms.RegexField(
        label=_("Username"), max_length=30,
        regex=r'^\w+$',
        help_text=_("30 characters or fewer. Letters, "
                    "underscores and digits only"),
        error_messages={'invalid':
                        _("This value may contain only letters, "
                          "underscores and numbers.")})

    def __init__(self, *args, **kwargs):
        self.helper = FormHelper()
        self.helper.form_action = reverse('ec:register')
        self.helper.add_input(Submit('submit', 'Submit'))
        super(RegisterForm, self).__init__(*args, **kwargs)


class LoginForm(AuthenticationForm):
    def __init__(self, *args, **kwargs):
        self.helper = FormHelper()
        self.helper.form_action = reverse('ec:login')
        self.helper.add_input(Submit('submit', 'Submit'))
        super(LoginForm, self).__init__(*args, **kwargs)
