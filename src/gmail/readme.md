# Gmail::Importer

The `import.rb` script contains the class `Gmail::Importer` which imports
messages from a local folder full of `.mime` files into a Gmail account.

The script is a one-off, but can be extended and parametrized to support more
use-cases and interactivity.

## Usage

```sh
bundle install # Only required once
bundle exec ruby import.rb
```

## Parameters

### `folder`

The `folder` to import from can for instance be the `MimeFiles` directory used
by Microsoft Outlook to store e-mail messages when you use "View Source".

### `user_id`

`user_id` is the e-mail address of the user to import the messages for, such
as `example@gmail.com`.

### `client_id_file`

`client_id_file` is the path to the JSON file containing the client ID as
generated under the "OAuth 2.0 Client IDs" in [Goog Cloud Console > API and
services > Credentials][creds].

### `token_file`

`token_file` is the path to a YAML file that will be written to in order to
store the OAuth 2.0 access tokens generated during authorization by the script.
The file may be created if it does not exist; I have not tested this.

## Functions

The script has two functions: `import!` and `list_labels`. These are described
in detail below.

### `import!`

The `import!` function performs the import of e-mail messages as configured
by the parameters described above.

### `list_labels`

The `list_labels` function lists the available labels in the authorized Gmail
account. This is useful for debugging and for determining the label IDs to use
when importing messages.

A valid label ID could be `Label_123901` for instance and is not available in
the Gmail web UI, afaik.

## Preparations

There were a plethora of steps I needed to perform to get authorization to work
and I have no idea which of them were actually necessary. I believe you need to
do the following:

1. [Create a Google Cloud project][create].
2. [Enable the Gmail API][enable] for the project.
3. From the project dashboard, go to [APIs & Services > Credentials][creds] and
   create a new OAuth 2.0 client ID.
4. Download the client ID JSON file and save it to a location of your choice.
   The location of where you save this file becomes the path of the
   `client_id_file` parameter.
5. Run the script with the `list_labels` function to figure out the ID of every
   label you'd like to have applied to every imported message. The labels needs
   to be created in the Gmail web UI before running the script.
6. Paste the label IDs into the `labels` array in the `import!` function.
7. Change `import.rb` to run with the `import!` function.
8. Change the parameters of the `import!` function to match your setup.

Step 5 through 8 should of course not require any changes to the `import.rb`
file, but should be parametrized and made interactive instead, as noted by the
`TODO` comments in the script.

[create]: https://cloud.google.com/resource-manager/docs/creating-managing-projects
[creds]: https://console.cloud.google.com/apis/credentials
[enable]: https://cloud.google.com/service-usage/docs/enable-disable
