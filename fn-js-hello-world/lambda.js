exports.hwHandler = async (event) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify(event),
    };
    return response;
};