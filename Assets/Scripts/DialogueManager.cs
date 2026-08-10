using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class DialogueManager : MonoBehaviour
{
    [Header("UI Objects")]
    public GameObject dialoguePanel;
    public Text speakerText;
    public Text dialogueBodyText;

    [Header("Settings")]
    public float typingSpeed = 0.03f;
    private Coroutine typingCoroutine;
    private float hideTimer = 0f;

    void Start()
    {
        if (dialoguePanel != null)
        {
            dialoguePanel.SetActive(false);
        }
    }

    void Update()
    {
        if (hideTimer > 0f)
        {
            hideTimer -= Time.deltaTime;
            if (hideTimer <= 0f)
            {
                CloseDialogue();
            }
        }
    }

    public void ShowDialogue(string speaker, string sentence, float displayDuration = 5f)
    {
        if (dialoguePanel == null || speakerText == null || dialogueBodyText == null)
        {
            // Fail safe logging in console if UI isn't linked
            Debug.Log($"[{speaker}]: {sentence}");
            return;
        }

        dialoguePanel.SetActive(true);
        speakerText.text = speaker;

        if (typingCoroutine != null)
        {
            StopCoroutine(typingCoroutine);
        }

        typingCoroutine = StartCoroutine(TypeSentence(sentence));
        hideTimer = displayDuration;
    }

    IEnumerator TypeSentence(string sentence)
    {
        dialogueBodyText.text = "";
        foreach (char letter in sentence.ToCharArray())
        {
            dialogueBodyText.text += letter;
            yield return new WaitForSeconds(typingSpeed);
        }
    }

    public void CloseDialogue()
    {
        if (dialoguePanel != null)
        {
            dialoguePanel.SetActive(false);
        }
    }
}
