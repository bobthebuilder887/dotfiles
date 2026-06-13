from IPython import get_ipython
from IPython.terminal.prompts import Prompts, Token
import time

ip = get_ipython()

class StatusPrompt(Prompts):
    def __init__(self, shell):
        super().__init__(shell)
        self.ok = True
        self.start_time = None
        self.elapsed = None
        self.error_type = None

    def in_prompt_tokens(self, cli=None):
        # TODO: fix for %cpaste
        # status = "✅" if self.ok else "❌"

        tokens = [
            (Token.Prompt, f"In[{self.shell.execution_count}] "),
            # (Token.Prompt, f"{status} "),
        ]

        if self.elapsed is not None:
            tokens.append((Token.PromptNum, f"{self.elapsed:.3f}s "))

        # if self.error_type:
        #     tokens.append((Token.Error, f"[{self.error_type}] "))

        tokens.append((Token.Prompt, ": "))
        return tokens

prompt = StatusPrompt(ip)

def pre_run(*args, **kwargs):
    prompt.ok = True
    prompt.error_type = None
    prompt.start_time = time.time()

def post_run(result, *args, **kwargs):
    prompt.ok = getattr(result, "success", True)

    err = getattr(result, "error_in_exec", None)
    prompt.error_type = type(err).__name__ if err else None

    if prompt.start_time:
        prompt.elapsed = time.time() - prompt.start_time

ip.events.register("pre_run_cell", pre_run)
ip.events.register("post_run_cell", post_run)

ip.prompts = prompt
