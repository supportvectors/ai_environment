# ai_environment
Configurator for a Python AI environment for SupportVectors AI training labs

1. `git clone` the repo to a folder of your choice
2. For a new uv project that you want to create, follow the below steps:
   
   ```shell
    uv init <my_project> --python=3.12
    cd <my_project>
    cp <my_path>/ai_environment/ensure_config.sh ./
    cp <my_path>/ai_environment/docs.tgz ./
    chmod +x ./ensure_config.sh
    ./ensure_config.sh ## Enter the appropriate path, project, description, url when prompted during the run of ensure_config.sh
   ```
3. Your project setup for `<my_project>` is now complete.
4. Note that these steps are needed only when you create a completely new UV based python project using the best practices recommended by SupportVectors.  If you are downloading an existing code repo uploaded by the SupportVectors team, you would just have to download the code repo and follow the steps as given in the project guide within the repo.
