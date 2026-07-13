# OpenAlex API Tracing & Integration Details (openAPIAlex)

This document traces the official OpenAlex API definitions and maps them directly to the endpoints and parameters required for the **Journal Trend Analyzer** project.

---

## 🔗 Base API URL
All API requests are sent to the root endpoint:
```http
https://api.openalex.org
```

---

## 🛠️ Required API Endpoints

### 1. Work Search & Citation Sorting
*   **Purpose**: Fulfills the **Topic Search** requirement, returning a list of matching scholarly articles.
*   **OpenAlex Doc Reference**: `/works` endpoint.
*   **HTTP Method**: `GET`
*   **Path**: `/works`
*   **Query Parameters**:
    | Parameter | Type | Required | Description |
    | :--- | :--- | :--- | :--- |
    | `search` | String | Yes | Free-text search query. Searches title, abstract, and full text (deprecated `title_and_abstract.search` filter replaced). |
    | `sort` | String | No | Sort criterion. Set to `cited_by_count:desc` to prioritize the most influential/cited works. |
    | `per_page` | Integer | No | Count of publications in response list. Set to `50` (standard baseline). |
    | `page` | Integer | No | Page number for pagination. Default is `1`. |

*   **Example Request**:
    ```http
    GET https://api.openalex.org/works?search=Artificial Intelligence&sort=cited_by_count:desc&per_page=50&page=1
    ```

---

### 2. Publication Detail & Abstract Retrieval
*   **Purpose**: Retrieves full metadata for a chosen paper, specifically the authorships, journal details, and the `abstract_inverted_index` map to parse text.
*   **OpenAlex Doc Reference**: `/works/{id}` endpoint.
*   **HTTP Method**: `GET`
*   **Path**: `/works/{id}` (e.g., `/works/W2741809807`)
*   **Example Request**:
    ```http
    GET https://api.openalex.org/works/W2741809807
    ```
*   **Response Payload Structure (Excerpt)**:
    ```json
    {
      "id": "https://openalex.org/W2741809807",
      "title": "Attention Is All You Need",
      "publication_year": 2017,
      "cited_by_count": 12450,
      "doi": "https://doi.org/10.48550/arxiv.1706.03762",
      "abstract_inverted_index": {
        "The": [0, 52],
        "dominant": [1],
        "sequence": [2, 5]
      },
      "authorships": [
        {
          "author": {
            "id": "https://openalex.org/A5043542792",
            "display_name": "Ashish Vaswani",
            "orcid": "https://orcid.org/0000-0002-3869-9026"
          }
        }
      ],
      "primary_location": {
        "source": {
          "id": "https://openalex.org/S137773268",
          "display_name": "Advances in Neural Systems",
          "publisher": "MIT Press",
          "type": "journal"
        }
      }
    }
    ```

---

### 3. Timeline Trend Grouping
*   **Purpose**: Group publications by year to plot the growth curve chart.
*   **OpenAlex Doc Reference**: `/works` grouping filters.
*   **HTTP Method**: `GET`
*   **Path**: `/works`
*   **Query Parameters**:
    - `search=<keyword>`
    - `group_by=publication_year`
*   **Example Request**:
    ```http
    GET https://api.openalex.org/works?search=Artificial Intelligence&group_by=publication_year
    ```
*   **Response Payload Structure**:
    ```json
    {
      "group_by": [
        {
          "key": "2023",
          "key_display_name": "2023",
          "count": 1420
        },
        {
          "key": "2022",
          "key_display_name": "2022",
          "count": 1280
        }
      ]
    }
    ```

---

### 4. Top Keywords Aggregation (Diagram 3)
*   **Purpose**: Groups works by their associated topics (keywords) to identify the most frequent terms.
*   **OpenAlex Doc Reference**: `/works` grouping filters.
*   **HTTP Method**: `GET`
*   **Path**: `/works`
*   **Query Parameters**:
    - `search=<keyword>`
    - `group_by=topics.id`
*   **Example Request**:
    ```http
    GET https://api.openalex.org/works?search=Artificial Intelligence&group_by=topics.id
    ```
*   **Response Payload Structure**:
    ```json
    {
      "group_by": [
        {
          "key": "https://openalex.org/topics/T10123",
          "key_display_name": "Neural Networks",
          "count": 320
        },
        {
          "key": "https://openalex.org/topics/T10456",
          "key_display_name": "Machine Learning",
          "count": 285
        }
      ]
    }
    ```

---

### 5. Top Journals Aggregation
*   **Purpose**: Returns the most active journals publishing papers on the selected topic.
*   **HTTP Method**: `GET`
*   **Path**: `/works`
*   **Query Parameters**:
    - `search=<keyword>`
    - `group_by=primary_location.source.id`
*   **Example Request**:
    ```http
    GET https://api.openalex.org/works?search=Artificial Intelligence&group_by=primary_location.source.id
    ```
*   **Response Payload Structure**:
    ```json
    {
      "group_by": [
        {
          "key": "https://openalex.org/S137773268",
          "key_display_name": "Journal of Machine Learning Research",
          "count": 145
        }
      ]
    }
    ```

---

### 6. Top Contributing Authors Aggregation
*   **Purpose**: Identifies authors who have published the highest number of papers on this topic.
*   **HTTP Method**: `GET`
*   **Path**: `/works`
*   **Query Parameters**:
    - `search=<keyword>`
    - `group_by=authorships.author.id`
*   **Example Request**:
    ```http
    GET https://api.openalex.org/works?search=Artificial Intelligence&group_by=authorships.author.id
    ```
*   **Response Payload Structure**:
    ```json
    {
      "group_by": [
        {
          "key": "https://openalex.org/A5043542792",
          "key_display_name": "Yoshua Bengio",
          "count": 32
        }
      ]
    }
    ```

---

## ⚡ Polite Pool Header Rule
OpenAlex throttles anonymous API requests. To prevent requests from failing with HTTP `429 Too Many Requests`, include your email in the HTTP request headers:
```http
User-Agent: JournalTrendAnalyzer/1.0 (mailto:your_email@domain.com)
```
This increases rate limits and places requests into the priority Polite Pool.
