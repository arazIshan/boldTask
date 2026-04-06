// Bold_NationalizeResponse.cls - JSON wrapper for Nationalize.io
/**
 * @description Wrapper class for Nationalize.io API response.
 *              Parses JSON and returns country with highest probability.
 * @author Araz
 * @date April 06, 2026
 * @version 1.1
 */
public without sharing class Bold_NationalizeResponse {
    public String name;
    public List<Country> country;

    public class Country {
        public String country_id;
        public Decimal probability;
    }

    /**
     * Returns the country_id with the highest probability.
     */
    public String getHighestProbabilityCountry() {
        if (country == null || country.isEmpty()) {
            return null; // Handle empty response scenario
        }

        Country highest = country[0]; // Start with first country

        // Find country with the highest probability
        for (Country c : country) {
            if (c.probability > highest.probability) {
                highest = c;
            }
        }
        return highest.country_id;
    }
}