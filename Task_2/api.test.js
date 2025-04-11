const axios = require('axios');

const API_URL = 'https://api.bitopro.com/v3/trading-history/btc_twd';

describe('Bitopro Trading History API', () => {
    test('API response should have valid structure', async () => {
        const resolution = '1h';
        const from = Math.floor(Date.now() / 1000) - 86400; // yesterday
        const to = Math.floor(Date.now() / 1000); // now
        const response = await axios.get(`${API_URL}?resolution=${resolution}&from=${from}&to=${to}`);
        expect(response.status).toBe(200);
        expect(response.data).toHaveProperty('data');
        expect(Array.isArray(response.data.data)).toBe(true);
        console.log(response.data.data)
        
        response.data.data.forEach(item => {
            expect(item).toHaveProperty('timestamp');
            expect(typeof item.timestamp).toBe('number');
            
            ['open', 'high', 'low', 'close', 'volume'].forEach(field => {
                expect(item).toHaveProperty(field);
                expect(typeof item[field]).toBe('string');
                expect(!isNaN(parseFloat(item[field]))).toBe(true);
            });
        });
    });

    test('from <= timestamp <= to ', async () => {
        const resolution = '1h';
        const from = Math.floor(Date.now() / 1000) - 86400;
        const to = Math.floor(Date.now() / 1000);
        const response = await axios.get(`${API_URL}?resolution=${resolution}&from=${from}&to=${to}`);
        const data = response.data.data;

        data.forEach(item => {
            //const timestamp = parseInt(item.timestamp) / 1000;
            const timestamp = item.timestamp / 1000;
            
            expect(timestamp).toBeLessThanOrEqual(to);
            expect(timestamp).toBeGreaterThanOrEqual(from);
        });
    });

    test('low <= open, close, high and high >= open, close, low', async () => {
        const resolution = '1h';
        const from = Math.floor(Date.now() / 1000) - 86400;
        const to = Math.floor(Date.now() / 1000);
        const response = await axios.get(`${API_URL}?resolution=${resolution}&from=${from}&to=${to}`);
        const data = response.data.data;

        data.forEach(item => {
            const open = parseFloat(item.open);
            const high = parseFloat(item.high);
            const low = parseFloat(item.low);
            const close = parseFloat(item.close);
            
            expect(low).toBeLessThanOrEqual(open);
            expect(low).toBeLessThanOrEqual(close);
            expect(low).toBeLessThanOrEqual(high);
            
            expect(high).toBeGreaterThanOrEqual(open);
            expect(high).toBeGreaterThanOrEqual(close);
            expect(high).toBeGreaterThanOrEqual(low);
        });
    });

    test('volume >= 0 ', async () => {
        const resolution = '1h';
        const from = Math.floor(Date.now() / 1000) - 86400;
        const to = Math.floor(Date.now() / 1000);
        const response = await axios.get(`${API_URL}?resolution=${resolution}&from=${from}&to=${to}`);
        const data = response.data.data;

        data.forEach(item => {
            const volume = parseFloat(item.volume);
            
            expect(volume).toBeGreaterThanOrEqual(0);
        });
    });

    test('no trade in invalid range of timestamp ', async () => {
        const resolution = '1h';
        const from = Math.floor(Date.now() / 1000);
        const to = Math.floor(Date.now() / 1000) + 86400;
        const response = await axios.get(`${API_URL}?resolution=${resolution}&from=${from}&to=${to}`);
        const data = response.data.data;
        console.log("data in invalid time")
        console.log(response.data)
        
        data.forEach(item => {
            const volume = parseFloat(item.volume);
            
            expect(volume).toEqual(0);
        });
        
    });
});