# Synthetix: AI Data Poisoning & Supply Chain Lab

![Synthetix Logo](https://img.shields.io/badge/Synthetix-AI_Security-blueviolet?style=for-the-badge)

Welcome to the **Synthetix** laboratory. This environment is designed to demonstrate modern attack vectors against AI-integrated applications, focusing on **Data Poisoning**, **Prompt Injection**, and **Insecure Code Execution**.

## Lab Overview

Synthetix is a fictional AI-first company that has integrated a proprietary Large Language Model (LLM) into their developer workflow. However, several critical misconfigurations have left their infrastructure vulnerable to a full system compromise.

### Objectives

1. **Information Gathering**: Use the CorpAI Assistant to discover internal infrastructure details.
2. **Data Poisoning**: Identify and exploit a misconfigured data storage bucket to poison the AI's training set.
3. **Remote Code Execution (RCE)**: Leverage the poisoned AI model to execute malicious code within the administrative toolset.
4. **Container Escape**: Escape the restricted container environment to retrieve the final flag from the host system.

## Architecture

The lab consists of the following services:

| Service | Port | Description |
| :--- | :--- | :--- |
| **Landing Page** | 80 | The main entry point for the Synthetix Portal. |
| **CorpAI Assistant** | 8000 | A Flask-based chatbot interface for the internal LLM. |
| **Data Science Lab** | 8888 | A Jupyter Notebook environment for AI developers. |
| **MinIO Storage** | 9000/9001 | Internal object storage for training data and model weights. |
| **AI-API** | 5000 | The backend service that serves completions and performs automated fine-tuning. |
| **Admin Bot** | - | An internal service that periodically executes AI-generated code snippets. |

## Quick Start

1.  **Access the Portal**: Open your browser and navigate to the VM's external IP on port 80.
2.  **Interact with CorpAI**: Try to find out where the training data is stored.
3.  **Explore the Storage**: Access the MinIO console (port 9001) or API (port 9000).
4.  **Poison the Model**: Upload a malicious `training_data.jsonl` to the `llm-data` bucket.
5.  **Wait for Execution**: Monitor the system for your payload to trigger in the `admin-tool`.

## Flag Location

The final flag is located at `/root/flag.txt` on the host system. You must achieve a container escape to read it.

---
*Developed for Advanced AI Security Training.*